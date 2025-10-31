//
//  OpenAIService.swift
//  KeyboardExtension
//
//  Created by Sanz on 30/10/2025.
//

import Foundation

class OpenAIService {
    static let shared = OpenAIService()

    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini"

    private init() {}

    private let systemPrompt = """
You are a writing improvement assistant. Your task is to improve the given text by fixing grammar, spelling, clarity, and style while maintaining the original meaning and tone.

Return ONLY the improved text without any explanations, introductions, or additional comments.

Examples:

Input: "i want go to store today maybe buy some thing"
Output: "I want to go to the store today to maybe buy something."

Input: "The report wasnt finished because there was to much work and not enought time for complete it properly"
Output: "The report wasn't finished because there was too much work and not enough time to complete it properly."

Input: "Hey whats up? i didnt saw you yesterday at the party were you sick or something"
Output: "Hey, what's up? I didn't see you yesterday at the party. Were you sick or something?"

Input: "The meetign will be held on monday at 3pm in the conference room on the second floor"
Output: "The meeting will be held on Monday at 3 PM in the conference room on the second floor."

Now improve this text:
"""

    func improveText(_ text: String, onStream: @escaping (String) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = KeychainHelper.shared.getAPIKey(), !apiKey.isEmpty else {
            completion(.failure(NSError(domain: "OpenAI", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key not configured. Please add your OpenAI API key in the app settings."])))
            return
        }

        guard let url = URL(string: apiURL) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.3,
            "max_tokens": 10_000,
            "stream": true
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
            return
        }
        request.httpBody = jsonData

        if #available(iOS 15.0, *) {
            Task(priority: .userInitiated) {
                do {
                    let (bytes, _) = try await URLSession.shared.bytes(for: request)
                    var fullText = ""

                    for try await line in bytes.lines {
                        // Ignore keep-alives and empty lines
                        guard line.hasPrefix("data:") else { continue }
                        let payload = line.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
                        if payload == "[DONE]" { break }
                        guard let data = payload.data(using: .utf8),
                              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let choices = json["choices"] as? [[String: Any]],
                              let first = choices.first,
                              let delta = first["delta"] as? [String: Any],
                              let content = delta["content"] as? String, !content.isEmpty else {
                            continue
                        }
                        fullText += content
                        DispatchQueue.main.async {
                            onStream(fullText)
                        }
                    }

                    DispatchQueue.main.async {
                        completion(.success(fullText.trimmingCharacters(in: .whitespacesAndNewlines)))
                    }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
        } else {
            // Fallback non-streaming (iOS < 15)
            var noStreamBody = requestBody
            noStreamBody["stream"] = false
            request.httpBody = try? JSONSerialization.data(withJSONObject: noStreamBody)
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error { completion(.failure(error)); return }
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let first = choices.first,
                      let message = first["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    return
                }
                let improved = content.trimmingCharacters(in: .whitespacesAndNewlines)
                DispatchQueue.main.async { onStream(improved); completion(.success(improved)) }
            }.resume()
        }
    }
}
