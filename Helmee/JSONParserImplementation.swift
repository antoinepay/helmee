import SwiftyJSON
import MapKit

protocol JSONParser {
    func checkErrorMessage(json: [String:Any]) -> String?
    func parse(json: [String: Any]) -> User
    func parse(json: [Any]) -> [Question]
    func parse(json: [Any]) -> [Category]
    func parse(json: [Any]) -> [Place]
    func parse(json: [Any]) -> [Answer]
    func parse(json: [String:Any]) -> [NewsStrate]
}

class JSONParserImplementation: JSONParser {

    private var dateFormatter = DateFormatter()

    //MARK: - JSONParser
    
    func checkErrorMessage(json: [String : Any]) -> String? {
        let json = JSON(json)
        let code = json["code"].intValue
        let message = json["message"].stringValue
        if message.isEmpty || code == 1 {
            return nil
        }
        return message
    }
    
    func parse(json: [String: Any]) -> User {
        let json = JSON(json)
        let id = json["id"].intValue
        let username = json["username"].stringValue
        let email = json["email"].stringValue
        let latitude = json["latitude"].stringValue
        let longitude = json["longitude"].stringValue
        let credits = json["credits"].intValue
        let token = json["token"].stringValue
        let rank = json["rank"].intValue
        let points = json["points"].intValue
        let helpInstructions = json["helpInstructions"].boolValue
        let categories = json["categories"].arrayValue
        var categoriesArray = [Category]()
        for category in categories {
            let categoryId = category["id"].intValue
            let categoryTitle = category["title"].stringValue
            let categoryColor = category["color"].stringValue
            let categoryImage = category["image"].intValue
            categoriesArray.append(Category(id: categoryId, title: categoryTitle, image: categoryImage, color: categoryColor))
        }
        let user = User(id: id,
                        username: username,
                        email: email,
                        latitude: latitude,
                        longitude: longitude,
                        credits: credits,
                        token: token,
                        rank: rank,
                        points: points,
                        helpInstructions: helpInstructions,
                        categories: categoriesArray)
        return user
    }
    
    static func parse(json: [String: Any]) -> User {
        let json = JSON(json)
        let id = json["id"].intValue
        let username = json["username"].stringValue
        let email = json["email"].stringValue
        let latitude = json["latitude"].stringValue
        let longitude = json["longitude"].stringValue
        let credits = json["credits"].intValue
        let token = json["token"].stringValue
        let rank = json["rank"].intValue
        let points = json["points"].intValue
        let helpInstructions = json["helpInstructions"].boolValue
        let categories = json["categories"].arrayValue
        var categoriesArray = [Category]()
        for category in categories {
            let categoryId = category["id"].intValue
            let categoryTitle = category["title"].stringValue
            let categoryColor = category["color"].stringValue
            let categoryImage = category["image"].intValue
            categoriesArray.append(Category(id: categoryId, title: categoryTitle, image: categoryImage, color: categoryColor))
        }
        let user = User(id: id,
                        username: username,
                        email: email,
                        latitude: latitude,
                        longitude: longitude,
                        credits: credits,
                        token: token,
                        rank: rank,
                        points: points,
                        helpInstructions: helpInstructions,
                        categories: categoriesArray)
        return user
    }
    
    func parse(json: [Any]) -> [Question] {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let questions: [Question] = json.flatMap { question in
            let qJson = JSON(question)
            let id = qJson["id"].intValue
            let authorId = qJson["authorId"].intValue
            let categoryName = qJson["category"].stringValue
            let categoryId = qJson["categoryId"].intValue
            let categoryColor = qJson["categoryColor"].stringValue
            let categoryImage = qJson["categoryImage"].intValue
            let text = qJson["text"].stringValue
            let latitude = qJson["latitude"].stringValue
            let longitude = qJson["longitude"].stringValue
            let radius = qJson["radius"].intValue
            let credits = qJson["credits"].intValue
            let dateString = qJson["date"].stringValue
            let accepted = qJson["accepted"].boolValue
            let answered = qJson["answered"].boolValue
            let usernameAuthor = qJson["username"].stringValue
            let date = dateFormatter.date(from: dateString)!
            var position = CLLocationCoordinate2D()
            if let lat = CLLocationDegrees(latitude), let lng = CLLocationDegrees(longitude) {
                position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            } else {
                position = CLLocationCoordinate2D()
            }
            let answersArray = qJson["answers"].arrayValue
            let answers: [Answer] = answersArray.flatMap { answer in
                let answerId = answer["id"].intValue
                let answerText = answer["text"].stringValue
                let answerQuestion = answer["question"].intValue
                let answerDateString = answer["date"].stringValue
                let answerDate = dateFormatter.date(from: answerDateString)
                let answerAccepted = answer["accepted"].boolValue
                let answerRejected = answer["rejected"].boolValue
                let answerAuthor = answer["authorId"].intValue
                let answerUsernameAuthor = answer["authorUsername"].stringValue
                return Answer(id: answerId, text: answerText, question: answerQuestion, date: answerDate!, accepted: answerAccepted, rejected: answerRejected, authorId: answerAuthor , authorUsername: answerUsernameAuthor)
            }
            return Question(id: id, text: text, idAuthor: authorId, usernameAuthor: usernameAuthor, credits: credits, position: position, radius: radius, date: date, accepted: accepted, answered: answered, numberOfAnswers: 0, category: Category(id: categoryId, title: categoryName, image: categoryImage, color: categoryColor), answers: answers)
        }
        return questions
    }
    
    func parse(json: [Any]) -> [Category] {
        let categories: [Category] = json.flatMap { category in
            let qJson = JSON(category)
            let id = qJson["id"].intValue
            let title = qJson["title"].stringValue
            let color = qJson["color"].stringValue
            let image = qJson["image"].intValue
            return Category(id: id, title: title, image: image, color: color)
        }
        return categories
    }
    
    func parse(json: [Any]) -> [Place] {
        let places: [Place] = json.flatMap { place in
            let qJson = JSON(place)
            let id = qJson["id"].intValue
            let name = qJson["name"].stringValue
            let latitude = qJson["latitude"].stringValue
            let longitude = qJson["longitude"].stringValue
            return Place(id: id, name: name, latitude: latitude, longitude: longitude)
        }
        return places
    }

    func parse(json: [Any]) -> [Answer] {
        let json = JSON(json)
        let answersArray = json.arrayValue
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let answers: [Answer] = answersArray.flatMap { answer in
            let answerId = answer["id"].intValue
            let answerText = answer["text"].stringValue
            let answerQuestion = answer["question"].intValue
            let answerDateString = answer["date"].stringValue
            let answerDate = dateFormatter.date(from: answerDateString)
            let answerAccepted = answer["accepted"].boolValue
            let answerRejected = answer["rejected"].boolValue
            let answerAuthor = answer["authorId"].intValue
            let answerUsernameAuthor = answer["authorUsername"].stringValue
            return Answer(id: answerId, text: answerText, question: answerQuestion, date: answerDate!, accepted: answerAccepted, rejected: answerRejected, authorId: answerAuthor , authorUsername: answerUsernameAuthor)
        }
        return answers
    }

    func parse(json: [String : Any]) -> [NewsStrate] {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let json = JSON(json)
        let strates = json["strates"].arrayValue
        return strates.flatMap { strate in
            let headerDictionary = strate["header"].dictionaryValue
            let headerTitle = headerDictionary["title"]?.stringValue ?? ""
            let headerColorString = headerDictionary["color"]?.stringValue ?? "#000000"
            let headerColor = UIColor(hexString: headerColorString)
            let headerSize = headerDictionary["size"]?.floatValue ?? 18
            let headerHeight = headerDictionary["height"]?.floatValue ?? 25
            let headerImage = headerDictionary["image"]?.intValue ?? 0
            let header = NewsHeaderFooter(
                title: headerTitle,
                color: headerColor,
                height: CGFloat(headerHeight),
                size: CGFloat(headerSize),
                image: headerImage
            )
            let questionsDictionary = strate["contents"].arrayValue
            let questions : [Question] = questionsDictionary.flatMap { q in
                let categoryName = q["category"].stringValue
                let categoryId = q["categoryId"].intValue
                let categoryColor = q["categoryColor"].stringValue
                let categoryImage = q["categoryImage"].intValue
                let id = q["id"].intValue
                let text = q["text"].stringValue
                let idAuthor = q["authorId"].intValue
                let usernameAuthor = q["authorUsername"].stringValue
                let latitude = q["latitude"].stringValue
                let longitude = q["longitude"].stringValue
                var position = CLLocationCoordinate2D()
                if let lat = CLLocationDegrees(latitude), let lng = CLLocationDegrees(longitude) {
                    position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                } else {
                    position = CLLocationCoordinate2D()
                }
                let radius = q["radius"].intValue
                let credits = q["credits"].intValue
                let dateString = q["date"].stringValue
                let accepted = q["accepted"].boolValue
                let answered = q["answered"].boolValue
                let date = dateFormatter.date(from: dateString)!
                let numberOfAnswers = q["numberOfAnswers"].intValue
                let category = Category(id: categoryId, title: categoryName, image: categoryImage, color: categoryColor)
                let answersArray = q["answers"].arrayValue
                let answers: [Answer] = answersArray.flatMap { answer in
                    let answerId = answer["id"].intValue
                    let answerText = answer["text"].stringValue
                    let answerQuestion = answer["question"].intValue
                    let answerDateString = answer["date"].stringValue
                    let answerDate = dateFormatter.date(from: answerDateString)
                    let answerAccepted = answer["accepted"].boolValue
                    let answerRejected = answer["rejected"].boolValue
                    let answerAuthor = answer["authorId"].intValue
                    let answerUsernameAuthor = answer["authorUsername"].stringValue
                    return Answer(id: answerId, text: answerText, question: answerQuestion, date: answerDate!, accepted: answerAccepted, rejected: answerRejected, authorId: answerAuthor , authorUsername: answerUsernameAuthor)
                }

                return Question(
                    id: id,
                    text: text,
                    idAuthor: idAuthor,
                    usernameAuthor: usernameAuthor,
                    credits: credits,
                    position: position,
                    radius: radius,
                    date: date,
                    accepted: accepted,
                    answered: answered,
                    numberOfAnswers: numberOfAnswers,
                    category: category,
                    answers: answers
                )
            }
            let footerDictionary = strate["footer"].dictionaryValue
            let footerTitle = headerDictionary["title"]?.stringValue ?? ""
            let footerColorString = headerDictionary["color"]?.stringValue ?? "#000000"
            let footerColor = UIColor(hexString: headerColorString)
            let footerSize = headerDictionary["size"]?.floatValue ?? 18
            let footerHeight = headerDictionary["height"]?.floatValue ?? 25
            let footer = NewsHeaderFooter(
                title: footerTitle,
                color: footerColor,
                height: CGFloat(footerHeight),
                size: CGFloat(footerSize),
                image: 0
            )
            return NewsStrate(questions: questions, header: header, footer: footer)
        }
    }
}
