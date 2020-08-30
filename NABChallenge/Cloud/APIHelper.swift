//
//  APIHelper.swift
//  NABChallenge
//
//  Created by user on 8/23/20.
//  Copyright © 2020 Sang Nguyen. All rights reserved.
//

import UIKit
import Alamofire

class APIHelper: NSObject {
    typealias APIHelperCompletion = (Result<Data, AFError>) -> Void
    
    class func cancelAllRequests() {
        AF.cancelAllRequests()
    }
    
    private var requests = [UUID: DataRequest]()
    
    func cancelAllRequests() {
        for (_, request) in requests {
            request.cancel()
        }
        requests = [:]
    }
    
    func cancelRequest(id: UUID) {
        requests[id]?.cancel()
        requests[id] = nil
    }
    
    @discardableResult
    func get(url: URL,
             params: [String: Any]? = nil,
             headers: [String: String]? = nil,
             completion: APIHelperCompletion? = nil) -> UUID {
        var httpHeaders: HTTPHeaders?
        if let headers = headers {
            httpHeaders = HTTPHeaders(headers)
        }
        let request = AF.request(url,
                                 method: .get,
                                 parameters: params,
                                 encoding: URLEncoding.default,
                                 headers: httpHeaders,
                                 interceptor: nil)
        { (request) in
            request.cachePolicy = .useProtocolCachePolicy
        }
        
        let id = request.id
        requests[id] = request
        
        request.cacheResponse(using: self)
        request.responseData { [weak self] (response) in
            self?.requests[id] = nil
            completion?(response.result)
        }
        return id
    }
    
    @discardableResult
    func post(url: URL,
              params: [String: Any]? = nil,
              headers: [String: String]? = nil,
              completion: APIHelperCompletion? = nil) -> UUID {
        var httpHeaders: HTTPHeaders?
        if let headers = headers {
            httpHeaders = HTTPHeaders(headers)
        }
        let request = AF.request(url,
                                 method: .post,
                                 parameters: params,
                                 encoding: URLEncoding.default,
                                 headers: httpHeaders)
        let id = request.id
        request.responseData { [weak self] (response) in
            self?.requests[id] = nil
            completion?(response.result)
        }
        requests[id] = request
        return id
    }
    
    @discardableResult
    func put(url: URL,
             params: [String: Any]? = nil,
             headers: [String: String]? = nil,
             completion: APIHelperCompletion? = nil) -> UUID {
        var httpHeaders: HTTPHeaders?
        if let headers = headers {
            httpHeaders = HTTPHeaders(headers)
        }
        let request = AF.request(url,
                                 method: .put,
                                 parameters: params,
                                 encoding: URLEncoding.default,
                                 headers: httpHeaders)
        let id = request.id
        request.responseData { [weak self] (response) in
            self?.requests[id] = nil
            completion?(response.result)
        }
        requests[id] = request
        return id
    }
    
    @discardableResult
    func delete(url: URL,
                params: [String: Any]? = nil,
                headers: [String: String]? = nil,
                completion: APIHelperCompletion? = nil) -> UUID {
        var httpHeaders: HTTPHeaders?
        if let headers = headers {
            httpHeaders = HTTPHeaders(headers)
        }
        let request = AF.request(url,
                                 method: .delete,
                                 parameters: params,
                                 encoding: URLEncoding.default,
                                 headers: httpHeaders)
        let id = request.id
        request.responseData { [weak self] (response) in
            self?.requests[id] = nil
            completion?(response.result)
        }
        requests[id] = request
        return id
    }
    
    @discardableResult
    func head(url: URL,
              headers: [String: String]? = nil,
              completion: APIHelperCompletion? = nil) -> UUID {
        var httpHeaders: HTTPHeaders?
        if let headers = headers {
            httpHeaders = HTTPHeaders(headers)
        }
        let request = AF.request(url,
                                 method: .head,
                                 encoding: URLEncoding.default,
                                 headers: httpHeaders)
        let id = request.id
        request.responseData { [weak self] (response) in
            self?.requests[id] = nil
            completion?(response.result)
        }
        requests[id] = request
        return id
    }
}

extension APIHelper: CachedResponseHandler {
    func dataTask(_ task: URLSessionDataTask, willCacheResponse response: CachedURLResponse, completion: @escaping (CachedURLResponse?) -> Void) {
        #if DEBUG
        NSLog("willCacheResponse \(response.response)")
        #endif
        
        var urlResponse = response.response
        if let httpResponse = urlResponse as? HTTPURLResponse, var headers = httpResponse.allHeaderFields as? [String: String], headers["Cache-Control"] == nil {
            if let url = httpResponse.url {
                headers["Cache-Control"] = "max-age=10800"
                if let newResponse = HTTPURLResponse(url: url, statusCode: httpResponse.statusCode, httpVersion: nil, headerFields: headers) {
                    urlResponse = newResponse
                    
                    #if DEBUG
                    NSLog("NEW RESPONSE HEADER \(headers)")
                    #endif
                }
            }
        }
        
        let cacheResponse = CachedURLResponse(response: urlResponse, data: response.data, userInfo: response.userInfo, storagePolicy: .allowed)
        
        completion(cacheResponse)
    }
}
