//
//  ContentView.swift
//  Outfit Picker App
//
//  Created by Miranda-Flores, Jennifer on 4/8/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - THEME COLORS
extension Color {
    static let bg = Color(red: 0.97, green: 0.97, blue: 0.95)
    static let card = Color.white
    static let accent = Color.black
    static let highlight = Color.blue.opacity(0.8)
}

// MARK: - Model
struct ClothingItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let image: UIImage?
    let category: String
    let season: String
    var isFavorite: Bool = false
}

// MARK: - Main View
struct ContentView: View {

    // MARK: Closet Data
    @State private var closet: [ClothingItem] = [
        ClothingItem(name: "T-Shirt", image: UIImage(named: "tshirt"), category: "Top", season: "Summer"),
        ClothingItem(name: "Hoodie", image: UIImage(named: "hoodie"), category: "Top", season: "Fall"),
        ClothingItem(name: "Jacket", image: UIImage(named: "jacket"), category: "Top", season: "Winter"),

        ClothingItem(name: "Jeans", image: UIImage(named: "jeans"), category: "Bottom", season: "Fall"),
        ClothingItem(name: "Shorts", image: UIImage(named: "shorts"), category: "Bottom", season: "Summer"),
        ClothingItem(name: "Sweatpants", image: UIImage(named: "sweatpants"), category: "Bottom", season: "Winter"),

        ClothingItem(name: "Sneakers", image: UIImage(named: "sneakers"), category: "Shoes", season: "All"),
        ClothingItem(name: "Boots", image: UIImage(named: "boots"), category: "Shoes", season: "Winter"),
        ClothingItem(name: "Sandals", image: UIImage(named: "sandals"), category: "Shoes", season: "Summer")
    ]

    // MARK: Outfit Selection
    @State private var selectedTop: ClothingItem?
    @State private var selectedBottom: ClothingItem?
    @State private var selectedShoes: ClothingItem?

    // MARK: Filters
    @State private var searchText = ""
    @State private var selectedSeason = "All"

    // MARK: Tabs
    @State private var selectedTab = "Closet"

    // MARK: Add Item
    @State private var showAddSheet = false
    @State private var newItemName = ""
    @State private var selectedCategory = "Top"
    @State private var selectedItemSeason = "Summer"

    // Photos
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            VStack {

                Picker("", selection: $selectedTab) {
                    Text("Closet").tag("Closet")
                    Text("Favorites").tag("Favorites")
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == "Closet" {
                    closetView
                } else {
                    favoritesView
                }
            }
            .background(Color.bg.ignoresSafeArea())
            .navigationTitle("Outfit Builder")
            .toolbar {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.accent)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            addItemSheet
        }
    }

    // MARK: CLOSET VIEW
    var closetView: some View {
        ScrollView {
            VStack(spacing: 18) {

                VStack(spacing: 12) {
                    OutfitItemView(title: "Top", item: selectedTop)
                    OutfitItemView(title: "Bottom", item: selectedBottom)
                    OutfitItemView(title: "Shoes", item: selectedShoes)
                }
                .padding(.horizontal)

                Button {
                    pickOutfit()
                } label: {
                    Text("Pick Outfit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.45, green: 0.60, blue: 0.45))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)

                searchBar
                
                seasonPicker

                VStack(spacing: 20) {
                    ClosetRow(title: "Tops",
                               items: filteredItems(for: "Top"),
                               selectedItem: selectedTop,
                               onSelect: { selectedTop = $0 },
                               onDelete: deleteItem,
                               onFavorite: toggleFavorite)

                    ClosetRow(title: "Bottoms",
                               items: filteredItems(for: "Bottom"),
                               selectedItem: selectedBottom,
                               onSelect: { selectedBottom = $0 },
                               onDelete: deleteItem,
                               onFavorite: toggleFavorite)

                    ClosetRow(title: "Shoes",
                               items: filteredItems(for: "Shoes"),
                               selectedItem: selectedShoes,
                               onSelect: { selectedShoes = $0 },
                               onDelete: deleteItem,
                               onFavorite: toggleFavorite)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
    }

    // MARK: FAVORITES
    var favoritesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Favorites ❤️")
                    .font(.title2.bold())
                    .padding(.horizontal)

                let favorites = closet.filter { $0.isFavorite }

                if favorites.isEmpty {
                    Text("No favorites yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(favorites) { item in
                        HStack {
                            if let img = item.image {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                            }

                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button {
                                toggleFavorite(item)
                            } label: {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.card)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 5)
                    }
                }
            }
        }
        .background(Color.bg)
    }

    // MARK: SEARCH
    var searchBar: some View {
        TextField("Search clothing...", text: $searchText)
            .padding()
            .background(Color.card)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accent.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal)
    }

    // MARK: SEASON
    var seasonPicker: some View {
        Picker("Season", selection: $selectedSeason) {
            Text("All").tag("All")
            Text("Spring").tag("Spring")
            Text("Summer").tag("Summer")
            Text("Fall").tag("Fall")
            Text("Winter").tag("Winter")
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: FUNCTIONS
    func filteredItems(for category: String) -> [ClothingItem] {
        closet.filter {
            $0.category == category &&
            (selectedSeason == "All" || $0.season == selectedSeason || $0.season == "All") &&
            (searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()))
        }
    }

    func toggleFavorite(_ item: ClothingItem) {
        if let index = closet.firstIndex(of: item) {
            closet[index].isFavorite.toggle()
        }
    }

    func deleteItem(_ item: ClothingItem) {
        closet.removeAll { $0.id == item.id }
    }

    func pickOutfit() {
        selectedTop = filteredItems(for: "Top").randomElement()
        selectedBottom = filteredItems(for: "Bottom").randomElement()
        selectedShoes = filteredItems(for: "Shoes").randomElement()
    }

    // MARK: ADD ITEM SHEET
    var addItemSheet: some View {
        VStack(spacing: 16) {

            Text("Add Item")
                .font(.title2.bold())

            TextField("Name", text: $newItemName)
                .padding()
                .background(Color.bg)
                .cornerRadius(10)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(12)
                } else {
                    Text("Select Photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.bg)
                        .cornerRadius(10)
                }
            }
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }

            Picker("Category", selection: $selectedCategory) {
                Text("Top").tag("Top")
                Text("Bottom").tag("Bottom")
                Text("Shoes").tag("Shoes")
            }
            .pickerStyle(.segmented)

            Picker("Season", selection: $selectedItemSeason) {
                Text("Spring").tag("Spring")
                Text("Summer").tag("Summer")
                Text("Fall").tag("Fall")
                Text("Winter").tag("Winter")
            }
            .pickerStyle(.segmented)

            Button {
                let newItem = ClothingItem(
                    name: newItemName,
                    image: selectedImage,
                    category: selectedCategory,
                    season: selectedItemSeason
                )

                closet.append(newItem)

                newItemName = ""
                selectedImage = nil
                selectedPhoto = nil
                showAddSheet = false
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(newItemName.isEmpty ? Color.gray : Color.accent)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .disabled(newItemName.isEmpty)
        }
        .padding()
    }
}

// MARK: CLOSET ROW
struct ClosetRow: View {
    let title: String
    let items: [ClothingItem]
    let selectedItem: ClothingItem?
    let onSelect: (ClothingItem) -> Void
    let onDelete: (ClothingItem) -> Void
    let onFavorite: (ClothingItem) -> Void

    var body: some View {
        VStack(alignment: .leading) {

            Text(title)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        VStack {
                            if let img = item.image {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(12)
                            }

                            Text(item.name)
                                .font(.caption)

                            Button {
                                onFavorite(item)
                            } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(10)
                        .background(Color.card)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.08), radius: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedItem?.id == item.id ? Color.accent : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture { onSelect(item) }
                        .onLongPressGesture { onDelete(item) }
                    }
                }
            }
        }
    }
}

// MARK: OUTFIT VIEW
struct OutfitItemView: View {
    let title: String
    let item: ClothingItem?

    var body: some View {
        VStack {
            Text(title).bold()

            if let item, let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(12)

                Text(item.name)
                    .font(.caption)
            } else {
                Text("-")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.card)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

#Preview {
    ContentView()
}
