//
//  GenrePickerView.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/28/22.
//

import SwiftUI

struct GenrePickerView: View {
    var body: some View {
        List(anExtensiveListOfGenres, id: \.self) { genre in
            Button {
                print(genre)
            } label: {
                Text(genre)
            }
        }
    }
}

struct GenrePickerView_Previews: PreviewProvider {
    static var previews: some View {
        GenrePickerView()
    }
}
