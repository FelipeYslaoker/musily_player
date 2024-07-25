/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'package:flutter/material.dart';

class Logger {
  static log(String errorLocation, Object? error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toString();

    // Check if error is not null, otherwise use an empty string
    final errorMessage = error != null ? '$error' : '';

    // Check if stackTrace is not null, otherwise use an empty string
    final stackTraceMessage = stackTrace != null ? '$stackTrace' : '';

    final logMessage =
        '[$timestamp] $errorLocation:$errorMessage\n$stackTraceMessage';

    debugPrint('\x1B[31m$logMessage\x1B[31m');
  }

  static alert(String message) {
    debugPrint('\x1B[0m$message\x1B[0m');
  }
}
