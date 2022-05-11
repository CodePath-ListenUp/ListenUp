//
//  GenrePickerView.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/28/22.
//

import Parse
import SwiftUI

struct GenrePickerView: View {
    @State private var availableGenres = Set<String>(["All Genres"])
    @Binding var currentGenre: String
    var body: some View {
        List(Array(availableGenres).sorted(), id: \.self) { genre in
            Button {
                currentGenre = genre
            } label: {
                HStack {
                    Text(genre)
                        .foregroundColor(Color(uiColor: .label))
                    Spacer()
                    if currentGenre == genre {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .onChange(of: currentGenre, perform: { newVal in
            filteringGenre = newVal
            shouldReloadFeed = true
            postToComeBackTo = nil
        })
        .onAppear {
            let query = Post.query()
            query?.includeKey("primaryGenreName")
            query?.findObjectsInBackground { results, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                else if let results = results as? [Post] {
                    for result in results {
                        availableGenres.insert(result.primaryGenreName)
                    }
                }
            }
        }
    }
}

//struct GenrePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        GenrePickerView(currentGenre: Binding<String>("All Genres"))
//    }
//}
