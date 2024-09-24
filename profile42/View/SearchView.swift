//
//  SearchView.swift
//  profile42
//
//  Created by Thibault Giraudon on 19/09/2024.
//

import SwiftUI

struct SearchView: View {
    @StateObject var api: API
    @State private var searchText: String = ""
    @FocusState private var isFocused: Bool
    @State private var searchUser: User?
    @State private var showAlert: Bool = false
    var body: some View {
        VStack {
            HStack {
                Text("Searches")
                    .padding()
                Spacer()
            }
            Divider()
            HStack {
                HStack {
                    TextField("Search something", text: $searchText)
                        .focused($isFocused)
                    if !searchText.isEmpty {
                        Image(systemName: "xmark.circle")
                            .onTapGesture {
                                searchText.removeAll()
                                isFocused = false
                            }
                    }
                }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                Button("Search") {
                    Task {
                        do {
                            searchUser = try await api.fetchData(API.UserEndPoint.search(login: searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()))
                            if let searchUser {
                                api.history.insert(searchUser, at: 0)
                            }
                        } catch {
                            showAlert = true
                            print(error)
                        }
                    }
                }
                .padding()
                .background(Color.cyan)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                    ForEach(api.history, id: \.id) { user in
                        VStack(spacing: 0) {
                            AsyncImage(url: URL(string: user.image.link)!) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal)
                            } placeholder: {
                                ProgressView()
                            }
                            Text(user.login)
                                .font(.headline)
                                .foregroundStyle(.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .overlay {
                                    Rectangle()
                                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                                }
                                .padding(.horizontal)
                        }
                        .onTapGesture {
                            api.selectedUser = user
                            api.activeTab = .otherProfile
                            api.navHistory.append(.otherProfile)
                            print(api.navHistory)
                            print(api.navHistory.count)
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("The user you're searching for doesn't exist."))
            
        }
    }
}

#Preview {
    SearchView(api: API())
}
