Just run and should work out of the box.

UIViews used: UILabel, UIPickerView, UITextField, UIButton
Architecture: Something similar to a MVC with a model, view and a controller.
We also have managers in this architecture to handle tasks such as storing 
precomputed data or performing network requests. One such manager is the CurrencyDataManager 
which is inchanrge of performing network calls to the api server to obtain currency data and 
also store list of companies.


WE also have enum to depict error handling and a Conversion Model to store the Codable data from API call

Ideally we would like to have HTTPModels to parse requests and data models to use with View Controllers

I was also considering dependancy injecting the manager into the VC and having a factory design pattern however the app was super small so I chose to simplify developement time.

Normally I would use SnapKit for my Constraints and ReactiveSwift to handle async network calls. It would also be useful to have Properties and Mutable Properties to handle changes in data.

Considered using an NSCache / Core Data to store our country list array as to not refetch each time.


Feedback about assignment:
The assignment was actually very straightforward and covers all the basics so I enjoyed it. It is also not at all time consuming and theres always room for improvement.
