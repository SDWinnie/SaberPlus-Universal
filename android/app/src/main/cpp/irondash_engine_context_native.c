// 🤖 Generated wholely or partially with Google Antigravity
// 16KB page-aligned C implementation of irondash_engine_context_native (0.5.5)
#include <jni.h>
#include <android/looper.h>

static JavaVM* g_shared_vm = 0;
static ALooper* g_main_looper = 0;
static jobject g_class_loader = 0;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved) {
    (void)reserved;
    JNIEnv* env = 0;
    if ((*vm)->GetEnv(vm, (void**)&env, JNI_VERSION_1_6) != JNI_OK || !env) {
        return JNI_VERSION_1_6;
    }

    jclass flutter_jni_cls = (*env)->FindClass(env, "io/flutter/embedding/engine/FlutterJNI");
    if (flutter_jni_cls) {
        jclass meta_cls = (*env)->GetObjectClass(env, flutter_jni_cls);
        if (meta_cls) {
            jmethodID get_loader = (*env)->GetMethodID(
                env,
                meta_cls,
                "getClassLoader",
                "()Ljava/lang/ClassLoader;"
            );
            if (get_loader) {
                jobject loader = (*env)->CallObjectMethod(env, flutter_jni_cls, get_loader);
                if (loader) {
                    g_class_loader = (*env)->NewGlobalRef(env, loader);
                }
            }
        }
    }

    g_shared_vm = vm;
    g_main_looper = ALooper_forThread();
    return JNI_VERSION_1_6;
}

__attribute__((visibility("default")))
JavaVM* irondash_engine_context_get_java_vm(void) {
    return g_shared_vm;
}

__attribute__((visibility("default")))
jobject irondash_engine_context_get_class_loader(void) {
    return g_class_loader;
}

__attribute__((visibility("default")))
ALooper* irondash_engine_context_get_main_looper(void) {
    return g_main_looper;
}
