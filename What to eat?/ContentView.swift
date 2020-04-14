//
//  ContentView.swift
//  What to eat?
//
//  Created by Christian Privitelli on 14/4/20.
//  Copyright © 2020 Christian Privitelli. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: [])
    var foods: FetchedResults<Food>
    
    @State private var isPresented = false
    @State private var randomSelected: Int = 0
    
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Button("Choose Random") {
                        if !self.foods.isEmpty {
                            let random = Int.random(in: 0..<self.foods.count)
                            self.randomSelected = random
                        } else {
                            self.randomSelected = 0
                        }
                    }
                    if !self.foods.isEmpty {
                        Text(foods[self.randomSelected].name!)
                            .font(.largeTitle)
                            .bold()
                        Text(foods[self.randomSelected].bld!)
                            .font(.caption)
                            .bold()
                        HStack {
                            Text(foods[self.randomSelected].timeToPrepare! + " to prepare.")
                                .font(.caption)
                            Text(foods[self.randomSelected].timeToCook! + " to cook.")
                                .font(.caption)
                        }
                        if self.foods[self.randomSelected].image != nil {
                            Image(uiImage: self.foods[self.randomSelected].image! as! UIImage)
                                .resizable()
                                .frame(maxWidth: 200, maxHeight: 200)
                                .padding()
                                .cornerRadius(20)
                                .scaledToFit()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                List {
                    ForEach(foods, id: \.id) { food in
                        NavigationLink(destination: FoodView(food: food)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(food.name!)
                                        .bold()
                                    Text(food.bld!)
                                        .font(.caption)
                                }
                                Spacer()
                                if food.image != nil {
                                    Image(uiImage: food.image! as! UIImage)
                                        .resizable()
                                        .frame(maxWidth: 25, maxHeight: 25)
                                        .padding()
                                        .cornerRadius(20)
                                        .scaledToFill()
                                }
                            }.frame(height: 30)
                        }
                    }
                    .onDelete(perform: removeFood)
                }
                .navigationBarTitle("What to Eat??")
                .navigationBarItems(trailing:
                    HStack {
                        EditButton()
                        Button("Add") {
                            self.isPresented = true
                        }
                        .sheet(isPresented: self.$isPresented) {
                            FoodForm(onDismiss: {self.isPresented = false}).environment(\.managedObjectContext, self.moc)
                        }
                    }
                )
            }
        }
    }
    
    func removeFood(at offsets: IndexSet) {
        for index in offsets {
            let food = foods[index]
            moc.delete(food)
            try? moc.save()
        }
    }
}

struct FoodView: View {
    @Environment(\.managedObjectContext) var moc
    var food: Food
    
    
    var body: some View {
        VStack {
            Text(food.name!)
                .font(.largeTitle)
                .bold()
            Text(food.bld!)
                .font(.callout)
            Text("Prepare time: \(food.timeToPrepare ?? " ")")
                .font(.callout)
            Text("Cook time: \(food.timeToCook ?? " ")")
                .font(.callout)
        }
    }
}

struct FoodForm: View {
    @Environment(\.managedObjectContext) var moc
    
    
    var onDismiss: () -> ()
    
    init(onDismiss: @escaping () -> ()) {
        self.onDismiss = onDismiss
    }
    
    @State private var name = ""
    @State private var bld = ""
    @State private var timeToPrepare = ""
    @State private var timeToCook = ""
    
    @State private var bldInt: Int = 0
    
    @State private var timeToPrepareInt: Int = 0
    @State private var timeToCookInt: Int = 0
    
    @State private var showImagePicker : Bool = false
    @State private var image : UIImage? = nil
    
    private var bldOptions = ["Breakfast", "Lunch", "Dinner"]
    private var timeOptions = ["Less than 5 mins", "5-10 mins", "10-15 mins", "15-20 mins", "20-25 mins", "25-30 mins", "30-35 mins", "35-40 mins", "40-45 mins", "45-50 mins", "50-55 mins", "55-60 mins", "1-1.5 hours", "1.5-2hours", "More than 2 hours"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                Form {
                    TextField("Name: ", text: self.$name)
                    Picker("Breakfast, lunch or dinner? ", selection: self.$bldInt) {
                        ForEach(0..<self.bldOptions.count) {
                            Text(self.bldOptions[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Section {
                        VStack(alignment: .leading) {
                            Text("Time to prepare:")
                            Picker("", selection: self.$timeToPrepareInt) {
                                ForEach(0..<self.timeOptions.count) {
                                    Text(self.timeOptions[$0])
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    Section {
                        VStack(alignment: .leading) {
                            Text("Time to cook:")
                            Picker("", selection: self.$timeToCookInt) {
                                ForEach(0..<self.timeOptions.count) {
                                    Text(self.timeOptions[$0])
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    Section {
                        Button("Add Image") {
                            self.showImagePicker = true
                        }.sheet(isPresented: self.$showImagePicker){
                            PhotoCaptureView(showImagePicker: self.$showImagePicker, image: self.$image)
                        }
                    }
                    if self.image != nil {
                        Image(uiImage: self.image!)
                            .resizable()
                            .padding()
                            .cornerRadius(20)
                            .scaledToFit()
                    }
                    Section {
                        Button("Save") {
                            let newItem = Food(context: self.moc)
                            newItem.id = UUID()
                            newItem.name = self.name
                            
                            if self.bldInt == 0 {
                                self.bld = "Breakfast"
                            } else if self.bldInt == 1 {
                                self.bld = "Lunch"
                            } else if self.bldInt == 2 {
                                self.bld = "Dinner"
                            } else {
                                self.bld = "?"
                            }
                            switch self.timeToPrepareInt {
                            case 0:
                                self.timeToPrepare = self.timeOptions[0]
                            case 1:
                                self.timeToPrepare = self.timeOptions[1]
                            case 2:
                                self.timeToPrepare = self.timeOptions[2]
                            case 3:
                                self.timeToPrepare = self.timeOptions[3]
                            case 4:
                                self.timeToPrepare = self.timeOptions[4]
                            case 5:
                                self.timeToPrepare = self.timeOptions[5]
                            case 6:
                                self.timeToPrepare = self.timeOptions[6]
                            case 7:
                                self.timeToPrepare = self.timeOptions[7]
                            case 8:
                                self.timeToPrepare = self.timeOptions[8]
                            case 9:
                                self.timeToPrepare = self.timeOptions[9]
                            case 10:
                                self.timeToPrepare = self.timeOptions[10]
                            case 11:
                                self.timeToPrepare = self.timeOptions[11]
                            case 12:
                                self.timeToPrepare = self.timeOptions[12]
                            case 13:
                                self.timeToPrepare = self.timeOptions[13]
                            case 14:
                                self.timeToPrepare = self.timeOptions[14]
                            default:
                                self.timeToPrepare = "?"
                            }
                            
                            switch self.timeToCookInt {
                            case 0:
                                self.timeToCook = self.timeOptions[0]
                            case 1:
                                self.timeToCook = self.timeOptions[1]
                            case 2:
                                self.timeToCook = self.timeOptions[2]
                            case 3:
                                self.timeToCook = self.timeOptions[3]
                            case 4:
                                self.timeToCook = self.timeOptions[4]
                            case 5:
                                self.timeToCook = self.timeOptions[5]
                            case 6:
                                self.timeToCook = self.timeOptions[6]
                            case 7:
                                self.timeToCook = self.timeOptions[7]
                            case 8:
                                self.timeToCook = self.timeOptions[8]
                            case 9:
                                self.timeToCook = self.timeOptions[9]
                            case 10:
                                self.timeToCook = self.timeOptions[10]
                            case 11:
                                self.timeToCook = self.timeOptions[11]
                            case 12:
                                self.timeToCook = self.timeOptions[12]
                            case 13:
                                self.timeToCook = self.timeOptions[13]
                            case 14:
                                self.timeToCook = self.timeOptions[14]
                            default:
                                self.timeToCook = "?"
                            }
                            newItem.bld = self.bld
                            newItem.image = self.image
                            newItem.timeToPrepare = self.timeToPrepare
                            newItem.timeToCook = self.timeToCook
                            try? self.moc.save()
                        }
                    }
                }
            }.navigationBarTitle("Add new food", displayMode: .large)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker : UIViewControllerRepresentable {
    
    @Binding var isShown: Bool
    @Binding var image: UIImage?
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> ImagePickerCordinator {
        return ImagePickerCordinator(isShown: $isShown, image: $image)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
}

class ImagePickerCordinator : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @Binding var isShown: Bool
    @Binding var image: UIImage?
    
    init(isShown : Binding<Bool>, image: Binding<UIImage?>) {
        _isShown = isShown
        _image   = image
    }
    
    //Selected Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        image = uiImage
        isShown = false
    }
    
    //Image selection got cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
}

struct PhotoCaptureView: View {
    
    @Binding var showImagePicker: Bool
    @Binding var image: UIImage?
    
    var body: some View {
        ImagePicker(isShown: $showImagePicker, image: $image)
    }
}
