#ifndef MBGL_UTIL_THREAD_LOCAL
#define MBGL_UTIL_THREAD_LOCAL

#include <mbgl/util/noncopyable.hpp>

#include <stdexcept>

#include <pthread.h>

namespace mbgl {
namespace util {

static pthread_once_t once = PTHREAD_ONCE_INIT;
static pthread_key_t key;

template <class T>
class tls : public noncopyable {
public:
    inline tls(T* val) {
        tls();
        set(val);
    }

    inline tls() {
        int ret = pthread_once(&once, []() {
            int createRet = pthread_key_create(&key, [](void *ptr) {
                delete reinterpret_cast<T *>(ptr);
            });

            if (createRet) {
                throw new std::runtime_error("Failed to init local storage key.");
            }
        });

        if (ret) {
            throw new std::runtime_error("Failed to init local storage.");
        }
    }

    inline ~tls() {
        if (pthread_key_delete(key)) {
            throw new std::runtime_error("Failed to delete local storage key.");
        }
    }

    inline T* get() {
        T* ret = reinterpret_cast<T*>(pthread_getspecific(key));
        if (!ret) {
            throw new std::runtime_error("Failed to get local storage.");
        }

        return ret;
    }

    inline void set(T* ptr) {
        if (pthread_setspecific(key, ptr)) {
            throw new std::runtime_error("Failed to set local storage.");
        }
    }
};

}
}

#endif
