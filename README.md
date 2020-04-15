# What to eat?

I was bored during lockdown and I can never decide what to eat so I made this to help decide.

Using SwiftUI forms, I can add a meal to this app with these options (at this point in time):
- Name
- Breakfast, lunch or dinner?
- Time to prepare
- Time to cook
- Image *(Using UIImagePicker and UIViewControllerRepresentable)*

These meals are stored persistantly in the CoreData model which means that I can exit the app and return and the data will be persisted. FetchRequest in SwiftUI fetches the specified meals from the CoreData model and updates the view when the results change. I am able to create an interactive list that displays the results of the FetchRequest.

At the top of the screen you can select a random meal and it will display a random one to you.

**TODO**
- [x] Make images not ugly
- [ ] Choose random based on filter eg. time to prepare and time to cook variables as well as breakfast lunch or dinner.
- [ ] What if you say have a meal that you've already prepared but is frozen and just need to cook. You should be able to add/subtract how many meals you have available but to not prepare.
- [ ] Make the detail view actually look nice with like an image at the top and some nice designs and stuff, also some controls for how many meals you have available and stuff
