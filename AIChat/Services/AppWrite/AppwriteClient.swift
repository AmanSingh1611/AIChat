//
//  AppwriteClient.swift
//  AIChat
//
//  Created by Aman on 23/04/26.
//

import Appwrite

let client = Client()
    .setEndpoint(AppwriteConstants.appwriteURL)
    .setProject(AppwriteConstants.appwriteProjectId)

let account = Account(client)
