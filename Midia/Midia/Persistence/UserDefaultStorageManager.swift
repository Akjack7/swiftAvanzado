//
//  UserDefaultStorageManager.swift
//  Midia
//
//  Created by Julio Martínez Ballester on 3/11/19.
//  Copyright © 2019 Yuju. All rights reserved.
//

import Foundation

class UserDefaultStorageManager: FavoritesProvidable {

    let userDefaults = UserDefaults.standard
    let mediaItemKind: MediaItemKind
    let favoritesKey: String

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init(withMediaItemKind mediaItemKind: MediaItemKind) {
        self.mediaItemKind = mediaItemKind
        self.favoritesKey = "favorite\(mediaItemKind)"
    }

    func getFavorites() -> [MediaItemDetailedProvidable]? {
        if let favoritesData = userDefaults.data(forKey: favoritesKey) {
            switch mediaItemKind {
            case .movie:
                return try? decoder.decode([Movies].self, from: favoritesData)
            default:
                fatalError("Media kind `\(mediaItemKind)` not supported yet")
            }
        }
        return nil
    }

    func getFavorite(byId favoriteId: String) -> MediaItemDetailedProvidable? {
        var retrieved: MediaItemDetailedProvidable? = nil
        if let favorites = getFavorites() {
            retrieved = favorites.filter({ $0.mediaItemId == favoriteId }).first
        }
        return retrieved
    }

    func add(favorite: MediaItemDetailedProvidable) {
        guard getFavorite(byId: favorite.mediaItemId) == nil else {
            return
        }
        if var favorites = getFavorites() {
            favorites.append(favorite)
            save(favorites)
        } else {
            save([favorite])
        }
    }

    func remove(favoriteWithId favoriteId: String) {
        if var favorites = getFavorites() {
            for (index, favorite) in favorites.enumerated() {
                if favoriteId == favorite.mediaItemId {
                    favorites.remove(at: index)
                    save(favorites)
                }
            }
        }
    }

    private func save(_ favorites: [MediaItemDetailedProvidable]) {
        do {
            switch mediaItemKind {
            case .movie:
                userDefaults.set(try encoder.encode(favorites as! [Movies]), forKey: favoritesKey)
            default:
                fatalError("not supported yet")
            }
            userDefaults.synchronize()
        } catch {
            fatalError("error enconding favorites")
        }
    }
}
