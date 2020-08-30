# Protocol-Oriented

WeatherSearchViewModelProtocol, WeatherViewCellProtocol, DataManagerProtocol, OpenWeatherMapAPIProtocol, DatabaseProtocol


# MVVM

View:                WeatherSearchViewController, WeatherViewCell
ViewModel:      WeatherSearchViewModel, WeatherViewModel
Model:              WeatherModel, CityModel


# Three-tier architecture

Presentation tier: Features

Application tier (business logic, logic tier, or middle tier): DataCenter

Data tier: Cloud, Database

    It is easy to implement UI first
    It is easy to change the data source from OpenWeatherMapAPI to another
    It is easy to make Cloud SDK for third parties
    

# Patterns applied:

1. Singleton: 

Database
DataManager


2. Facade:  

DataManager
    
    func search(_ filter: OpenWeatherMapAPI.SearchFilter, completion: @escaping SearchCompletion)

    WeatherSearchViewModel just need to know the input and output of a seach. It doesn't care about where data come (from database or api). 


# Checklist

1. Programming language: Swift is required, Objective-C is optional. (Done)
2. Design app's architecture (recommend VIPER or MVP, MVVM but not mandatory)  (Done MVVM)
3. UI should be looks like in attachment. (Done)
4. Write UnitTests  (Done)
5. Acceptance Tests
6. Exception handling  (Done)
7. Caching handling  (Done)
8. Accessibility for Disability Supports:
a. VoiceOver: Use a screen reader.  (Done)
b. Scaling Text: Display size and font size: To change the size of items on your screen,
adjust the display size or font size.  (Done)
9. Entity relationship diagram for the database and solution diagrams for the
components, infrastructure design if any
10.Readme file includes:
a. Brief explanation for the software development principles, patterns & practices being
applied  (Done)
b. Brief explanation for the code folder structure and the key Java/Kotlin libraries and
frameworks being used
c. All the required steps in order to get the application run on local computer  (Done)
d. Checklist of items the candidate has done.  (Done)
