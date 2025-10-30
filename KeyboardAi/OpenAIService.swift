//
//  OpenAIService.swift
//  KeyboardAi
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

    func improveText(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {
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

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.3,
            "max_tokens": 1000
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
            return
        }

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {

                    let improvedText = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(.success(improvedText))
                } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let error = json["error"] as? [String: Any],
                          let errorMessage = error["message"] as? String {
                    completion(.failure(NSError(domain: "OpenAI", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
