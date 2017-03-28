//
//  Result.swift
//  MiniDOM
//
//  Copyright 2017 Anodized Software, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/**
 Used to represent whether an operation was successful or encountered an error.
 */
public enum Result<SuccessType> {
    /**
     Indicates the operation was successful and resulted in the provided
     associated value.
     */
    case success(SuccessType)

    /**
     Indicates the parsing operation failed and resulted in the provided
     associated error value.
     */
    case failure(Error)

    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /**
     Returns the assoicated value if the result is a success, `nil` otherwise.
     */
    public var value: SuccessType? {
        if case let .success(value) = self {
            return value
        }

        return nil
    }

    /**
     Returns the associated error value if the result is a failure, `nil`
     otherwise.
     */
    public var error: Error? {
        if case let .failure(error) = self {
            return error
        }
        
        return nil
    }
}
