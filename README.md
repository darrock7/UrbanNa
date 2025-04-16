# UrbanNa

## Our Goal 

UrbanNa aims to simplify and accelerate the process of reporting and resolving urban infrastructure
issues by creating a centralized platform where citizens can easily document problems while providing
officials with the data needed to make informed decisions about resource allocation. Specifically, the
system will help users identify and report issues like potholes, broken streetlights, fallen trees, and other
urban infrastructure problems, track the status of their reports, and visualize problem patterns across their
community.

## Technical Approach 
1. Frontend: A cross-platform framework (e.g., Flutter, React Native) in order to reach more users
2. Backend: Node.js with Express
3. Database: A NoSQL database (e.g., MongoDB)
4. Machine Learning: Simple ML model to validate images according to severity

# Repo Format
  helpers      
  models       
  providers    
  screens      
  views        
We will have a few folders that will be designated to help maintain the structure of the app. This will include the providers, which will manage the state of the current app, the models folder to define the data structures shared across different components, and the helpers directory, which will contain utility functions and overall logic we need to develop. The screens folder will store the different user interface pages of the app like Home, Settings, Report Issue Screen while the views directory will include smaller, modular widgets used within those screens like the map display.
