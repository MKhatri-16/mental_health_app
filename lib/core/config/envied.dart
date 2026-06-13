import 'package:envied/envied.dart';

part 'envied.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'GEMINI_API_KEY')
  static final String geminiApiKey = _Env.geminiApiKey;

  @EnviedField(varName: 'HF_TOKEN')
  static final String hfToken = _Env.hfToken;

  @EnviedField(varName: 'GROQ_API_KEY')
  static final String groqApiKey = _Env.groqApiKey;
}
