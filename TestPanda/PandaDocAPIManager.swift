//
//  PandaDocApiManager.swift
//  TestPanda
//
//  Created by Toseef on 4/26/21.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case badURL
    case noData
}

/// APIRouter is class to create request from given param.
/// - Author: Toseef

// MARK: - Server extension for url & Product Id

enum PandaDocRouter: URLRequestConvertible {
    case getTemplates, createDocument(Parameters), sendDocument(id: String, param: Parameters)
    case shareDocument(id: String, param: Parameters)

    var baseURL: URL {
        return URL(string: "https://api.pandadoc.com/public/v1")!
    }

    var method: HTTPMethod {
        switch self {
        case .getTemplates: return .get
        case .createDocument: return .post
        case .sendDocument: return .post
        case .shareDocument: return .post
        }
    }

    var path: String {
        switch self {
        case .getTemplates: return "templates"
        case .createDocument: return "documents"
        case .sendDocument(let id, param: _) : return "documents/\(id)/send"
        case .shareDocument(let id, param: _) : return "documents/\(id)/session"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request.headers.add(.contentType("application/json"))
        request.headers.add(.authorization("API-Key 6c4963a1a13639bb16121084a60160e9973d377c"))

        switch self {
        case let .createDocument(parameters):
            request = try Alamofire.JSONEncoding.default.encode(request, with: parameters)
        case let .sendDocument(_, parameters):
            request = try Alamofire.JSONEncoding.default.encode(request, with: parameters)
        case let .shareDocument(_, parameters):
            request = try Alamofire.JSONEncoding.default.encode(request, with: parameters)

        default:
            break
        }
        return request
    }
}

class PandaDocAPIManager {

    static let shared = PandaDocAPIManager()

    var sessionURL: String {
        return "https://app.pandadoc.com/s/"
    }
    
    func getTemplates(completion: @escaping (Result<[Template],Error>) -> Void)  {

        AF.request(PandaDocRouter.getTemplates).responseJSON { response in
            debugPrint(response)
            print("\n URL:\(response.request?.url?.absoluteString ?? "" )")
            guard let itemsData = response.data else {
                completion(.failure(NetworkError.badURL))
                return
            }

            do {
                let decoder = JSONDecoder()
                let items = try decoder.decode(TemplateResult.self, from: itemsData)
                DispatchQueue.main.async {
                    completion(.success(items.results))
                }
            } catch {
                completion(.failure(NetworkError.noData))
            }
        }
    }

    func createDoc(param: Parameters, completion: @escaping (Result<Any,Error>) -> Void)  {

        AF.request(PandaDocRouter.createDocument(param))
            .responseJSON { response in
            debugPrint(response)

            switch response.result {
            case .success(let data):
                if let dictionary = data as? [AnyHashable: Any] {
                    print("Got a dictionary: \(dictionary)")
                    DispatchQueue.main.async {
                        completion(.success(dictionary))
                    }
                } else {
                    print(" Not Parse : \(data)")
                }

            case .failure(let aferror):
                completion(.failure(aferror))
            }
        }
    }


    func sendDocument(docID: String, param: Parameters, completion: @escaping (Result<Any,Error>) -> Void)  {

        AF.request(PandaDocRouter.sendDocument(id: docID, param: param))
            .responseJSON { response in
            debugPrint(response)

            switch response.result {
            case .success(let data):
                if let dictionary = data as? [AnyHashable: Any] {
                    print("Got a dictionary: \(dictionary)")
                    DispatchQueue.main.async {
                        completion(.success(dictionary))
                    }
                } else {
                    print(" Not Parse : \(data)")
                }

            case .failure(let aferror):
                completion(.failure(aferror))
            }
        }
    }

    func shareDocument(docID: String, param: Parameters, completion: @escaping (Result<Any,Error>) -> Void)  {

        AF.request(PandaDocRouter.shareDocument(id: docID, param: param))
            .responseJSON { response in
            debugPrint(response)

            switch response.result {
            case .success(let data):
                if let dictionary = data as? [AnyHashable: Any] {
                    print("Got a dictionary: \(dictionary)")
                    DispatchQueue.main.async {
                        completion(.success(dictionary))
                    }
                } else {
                    print(" Not Parse : \(data)")
                }

            case .failure(let aferror):
                completion(.failure(aferror))
            }
        }
    }
}

struct TemplateResult: Codable {
    let results: [Template]
}

struct Template: Codable {
    let id: String
    let name: String
}
