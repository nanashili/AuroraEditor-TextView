//
//  PthreadLock.swift
//  CodeEditTextView
//
//  Created by Nanashi Li on 09/12/23.
//

import Foundation

/// `PthreadLock` provides a simple and straightforward wrapper around the POSIX threads (pthread) mutex APIs.
/// This class allows for safe multithreaded access to resources by locking and unlocking a mutex.
/// It is important to use this lock to prevent data races and other threading issues in a concurrent environment.
///
/// - See Also: [Stack Overflow: Is it possible to determine the thread holding a mutex?](https://stackoverflow.com/questions/3483094/is-it-possible-to-determine-the-thread-holding-a-mutex)
/// - See Also: [Thread sanitiser v mutex](https://forums.swift.org/t/thread-sanitiser-v-mutex/54515)
class PthreadLock {
    private var _lock = pthread_mutex_t()

    /// Initializes a new mutex.
    /// This function initializes the mutex with default attributes.
    /// In case of failure during initialization, it will trigger an assertion in debug mode.
    init() throws {
        _lock = pthread_mutex_t()
        let result = pthread_mutex_init(&_lock, nil)
        guard result == 0 else {
            throw PthreadError.initializationFailed(code: result)
        }
    }

    /// Acquires the lock.
    /// This function locks the mutex, blocking the current thread if the mutex is not available.
    /// If the mutex is already locked by another thread, the calling thread will block until the mutex becomes available.
    /// In case of failure to lock, it will trigger an assertion in debug mode.
    func lock() throws {
        let result = pthread_mutex_lock(&_lock)
        guard result == 0 else {
            throw PthreadError.lockingFailed(code: result)
        }
    }

    /// Releases the lock.
    /// This function unlocks the mutex, allowing other threads to acquire the lock.
    /// In case of failure to unlock, it will trigger an assertion in debug mode.
    func unlock() throws {
        let result = pthread_mutex_unlock(&_lock)
        guard result == 0 else {
            throw PthreadError.unlockingFailed(code: result)
        }
    }

    /// Deinitializes the mutex.
    /// This function destroys the mutex. The mutex must not be locked or in use by another thread during destruction.
    /// In case of failure during destruction, it will trigger an assertion in debug mode.
    deinit {
        pthread_mutex_destroy(&_lock)
        // Note: No error handling needed here in most cases
    }
}

/// Represents errors that can occur when working with Pthread mutexes.
enum PthreadError: Error {
    case initializationFailed(code: Int32)
    case lockingFailed(code: Int32)
    case unlockingFailed(code: Int32)
}
