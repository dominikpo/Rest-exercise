import Foundation

struct DocumentsContainer: Decodable {
    var documents: [Country]
}

struct Country: Decodable {
    private enum RootCodingKeys: String, CodingKey {
        case ID = "name"
        case createTime
        case updateTime
        case fields
    }

    private enum NestedCodingKeys: String, CodingKey {
        case name
        case currency
        case capital
        case native
        case continent
        case phone
        case languages
    }

    private enum StringValueCodingKeys: String, CodingKey {
        case stringValue
    }

    private enum ArrayValueCodingKeys: String, CodingKey {
        case arrayValue
    }

    private enum ArrayValueNestedCodingKeys: String, CodingKey {
        case values
    }

    var ID: String
    var name: String
    var currency: String
    var capital: String
    var native: String
    var continent: String
    var phone: String
    var createTime: Date
    var updateTime: Date
    var languages: [String]

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let nestedContainer = try rootContainer.nestedContainer(keyedBy: NestedCodingKeys.self, forKey:.fields)
        ID = (try rootContainer.decode(String.self, forKey: .ID) as NSString).lastPathComponent
        name = try nestedContainer.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .name).decode(String.self, forKey: .stringValue)
        currency = try nestedContainer.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .currency).decode(String.self, forKey: .stringValue)
        capital = try nestedContainer.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .capital).decode(String.self, forKey: .stringValue)
        native = try nestedContainer.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .native).decode(String.self, forKey: .stringValue)
        continent = try nestedContainer.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .continent).decode(String.self, forKey: .stringValue)
        phone = try nestedContainer.nestedContainer(keyedBy: StringValueCodingKeys.self, forKey: .phone).decode(String.self, forKey: .stringValue)
        var langs = try nestedContainer.nestedContainer(keyedBy: ArrayValueCodingKeys.self, forKey: .languages).nestedContainer(keyedBy: ArrayValueNestedCodingKeys.self, forKey: .arrayValue).nestedUnkeyedContainer(forKey: .values)
        var languages: [String] = []
        while (!langs.isAtEnd) {
            languages.append(try langs.nestedContainer(keyedBy: StringValueCodingKeys.self).decode(String.self, forKey: .stringValue))
        }
        self.languages = languages
        createTime = try rootContainer.decode(Date.self, forKey: .createTime)
        updateTime = try rootContainer.decode(Date.self, forKey: .updateTime)

    }
}

