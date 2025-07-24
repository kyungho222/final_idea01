import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

// 서비스 및 유틸리티 import
import 'services/audio_service.dart';
import 'services/ai_service.dart';
import 'services/permission_service.dart';
import 'services/screen_service.dart';
import 'services/tts_service.dart';
import 'services/accessibility_service.dart';
import 'services/network_service.dart';

// 모델 import
import 'models/app_state.dart';
import 'models/grid_item.dart';
import 'models/ui_element.dart';

// UI 컴포넌트 import
import 'ui/screens/main_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/widgets/voice_status_widget.dart';
import 'ui/widgets/grid_widget.dart';
import 'ui/widgets/touch_indicator.dart';
import 'ui/widgets/accessibility_overlay.dart';

// 설정 import
import 'config/app_config.dart';
import 'config/grid_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 앱 초기화
  await AppConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '음성인식 AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
