//
//  API.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import Foundation

class API {
    
    let baseAPIString = "https://api.intra.42.fr/v2/me"
    
    func fetchUserData(token: String) {
        let APIString = baseAPIString
        if let apiURL = URL(string: APIString) {
            print(apiURL)
            var request = URLRequest(url: apiURL)
            request.httpMethod = "GET"
            print(token)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                }
                
                guard let data = data else {
                    print("No data")
                    return
                }
               print(response ?? "No response")
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    print(user)
                } catch {
                    print(error)
                }
            }
            task.resume()
        } else {
            print(APIString)
        }
        
    }
}
