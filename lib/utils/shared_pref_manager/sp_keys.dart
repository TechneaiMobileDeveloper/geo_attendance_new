  import 'package:flutter/foundation.dart';

  enum SPKeys {
    loginUserData,
    verifyEmail,
    instanceId,
    fcmToken,
    isFirst,
    googleAccessToken,
    googleRefreshToken,
    isGoogleSyncEnabled,
    msAccessToken,
    msRefreshToken,
    msTokenExpirationDate,
    isMsSyncEnabled,
    deleteUser,
    activeUser,
    deactivateUser,
    editUser,
    ipAddress,
    httpMethod
  }

  extension SPKeysExtensions on SPKeys {
    String get value => describeEnum(this);
  }
