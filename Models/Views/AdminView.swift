//
//  AdminView.swift
//  Quote_Generator
//
//  Created by Jahaan Suthar on 7/11/26.
//

import SwiftUI
import SwiftData

struct AdminView: View {

    @Query(sort: \User.fullName)
    private var users: [User]

    var body: some View {

        NavigationStack {

            List {

                if users.isEmpty {

                    ContentUnavailableView(
                        "No Users",
                        systemImage: "person.slash",
                        description: Text("No accounts have been created yet.")
                    )

                } else {

                    ForEach(users) { user in

                        VStack(alignment: .leading, spacing: 8) {

                            Text(user.fullName)
                                .font(.headline)

                            Text(user.email)
                                .foregroundStyle(.secondary)

                            Text(user.password)
                                .font(.caption)
                                .foregroundStyle(.gray)

                        }
                        .padding(.vertical, 6)

                    }

                }

            }
            .navigationTitle("Database")

        }

    }
}

#Preview {
    AdminView()
}
