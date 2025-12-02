import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notes_page.dart';

final supabase = Supabase.instance.client;

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  String? _errorMessage;

  Future<void> _authAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ✅ Валидация
    if (email.isEmpty || password.isEmpty) {
      _showError('✏️ Заполните все поля');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showError('📧 Введите корректный email');
      return;
    }

    if (password.length < 6) {
      _showError('🔒 Пароль должен содержать минимум 6 символов');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // 🔐 Вход
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        print('✅ Вход успешен: ${response.user?.email}');
      } else {
        // 📝 Регистрация
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );
        
        print('✅ Регистрация для: ${response.user?.email}');
        
        // 📩 Проверяем сессию (если сессия null, значит требуется подтверждение email)
        if (response.session == null) {
          _showSuccess(
            '📩 Регистрация успешна! Проверьте почту для подтверждения email.\n'
            'После подтверждения войдите в аккаунт.'
          );
          _clearFields();
          setState(() => _isLogin = true);
          return;
        }
        
        // Если сессия есть, значит регистрация прошла без подтверждения
        _showSuccess('🎉 Регистрация успешна! Добро пожаловать!');
      }
      
      // 🚀 Переход к заметкам
      await _navigateToNotes();
      
    } on AuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showError('⚠️ Ошибка: ${e.toString()}');
      print('❌ Ошибка: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToNotes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NotesPage()),
      );
    } else {
      _showError('❌ Не удалось войти. Попробуйте еще раз.');
    }
  }

  void _handleAuthError(AuthException e) {
    String message = '🔐 Ошибка аутентификации';
    
    final errorMessage = e.message.toLowerCase();
    
    if (errorMessage.contains('invalid login credentials')) {
      message = '❌ Неверный email или пароль';
    } else if (errorMessage.contains('user already registered')) {
      message = '👤 Пользователь уже зарегистрирован';
      setState(() => _isLogin = true);
    } else if (errorMessage.contains('email not confirmed')) {
      message = '📧 Подтвердите email адрес';
    } else if (errorMessage.contains('password should be at least')) {
      message = '🔒 Пароль должен быть не менее 6 символов';
    } else {
      message = '⚠️ ${e.message}';
    }
    
    _showError(message);
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  void initState() {
    super.initState();
    // Проверяем, если пользователь уже авторизован
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null && mounted) {
        print('✅ Пользователь уже авторизован: ${session.user.email}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NotesPage()),
        );
      }
    } catch (e) {
      print('⚠️ Ошибка при проверке сессии: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Notes - Вход'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.note_alt,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              _isLogin ? 'Вход в аккаунт' : 'Регистрация',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLogin 
                ? 'Войдите для доступа к заметкам'
                : 'Создайте новый аккаунт',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // Поле для ошибок
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _authAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Войти' : 'Зарегистрироваться',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (!_isLoading)
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _errorMessage = null;
                }),
                child: Text(
                  _isLogin
                      ? 'Нет аккаунта? Зарегистрироваться'
                      : 'Уже есть аккаунт? Войти',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            
            if (!_isLogin)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Пароль должен содержать минимум 6 символов',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}