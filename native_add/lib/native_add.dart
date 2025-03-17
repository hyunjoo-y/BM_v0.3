
import 'native_add_platform_interface.dart';
import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX
import 'package:ffi/ffi.dart';

typedef NATTraversalAdapterConstructorNative = Pointer<Void> Function(Pointer<Utf8>, Uint16);
typedef NATTraversalAdapterConstructor = Pointer<Void> Function(Pointer<Utf8>, int);
typedef NATTraversalAdapterDestructorNative = Void Function(Pointer<Void>);
typedef NATTraversalAdapterDestructor = void Function(Pointer<Void>);
typedef PerformStunOperationNative = Void Function(Pointer<Void>);
typedef PerformStunOperation = void Function(Pointer<Void>);

typedef GetICECandidatesNative = Pointer<Utf8> Function(Pointer<Void>);
typedef GetICECandidates = Pointer<Utf8> Function(Pointer<Void>);


final DynamicLibrary nativeBmLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative_bm.so")
    : DynamicLibrary.process();

final NATTraversalAdapterConstructor createAdapter = nativeBmLib
    .lookup<NativeFunction<NATTraversalAdapterConstructorNative>>("createNATTraversalAdapter")
    .asFunction<NATTraversalAdapterConstructor>();

final NATTraversalAdapterDestructor deleteAdapter = nativeBmLib
    .lookup<NativeFunction<NATTraversalAdapterDestructorNative>>("deleteNATTraversalAdapter")
    .asFunction<NATTraversalAdapterDestructor>();

final PerformStunOperation performStunOperation = nativeBmLib
    .lookup<NativeFunction<PerformStunOperationNative>>("performSTUNOperation")
    .asFunction<PerformStunOperation>();

final getICECandidates = nativeBmLib
    .lookup<NativeFunction<GetICECandidatesNative>>("getICECandidatesJson")
    .asFunction<GetICECandidates>();

class NativeAdd {
  Future<String?> getPlatformVersion() {
    return NativeAddPlatform.instance.getPlatformVersion();
  }

  late Pointer<Void> _adapter;

  void create(String server, int port) {
    final serverPtr = server.toNativeUtf8();
    _adapter = createAdapter(serverPtr, port);
    calloc.free(serverPtr);
  }

  void performSTUN() {
    performStunOperation(_adapter);
  }


  List<String> fetchICECandidates() {
    final resultPtr = getICECandidates(_adapter);
    final result = resultPtr.toDartString();
    calloc.free(resultPtr);
    return result.split(',');
  }
  

  void dispose() {
    deleteAdapter(_adapter);
  }


  
}
