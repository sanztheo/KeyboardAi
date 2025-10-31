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

    enum PromptKind { case improve, shorten, lengthen }

    private func prompt(for kind: PromptKind) -> String {
        switch kind {
        case .improve: return ImprovePrompt.text
        case .shorten: return ShortenPrompt.text
        case .lengthen: return LengthenPrompt.text
        }
    }

    func improveText(_ text: String, kind: PromptKind = .improve, completion: @escaping (Result<String, Error>) -> Void) {
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
                ["role": "system", "content": prompt(for: kind)],
                ["role": "user", "content": text]
            ],
            "temperature": 0.3,
            "max_tokens": 10_000,
            "stream": false
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
