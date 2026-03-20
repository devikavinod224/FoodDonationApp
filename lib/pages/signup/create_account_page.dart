import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String? _userType; // 'shopkeeper' or 'receiver'
  bool _showPassword = false;
  bool _isDropdownOpen = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Color get _accentColor {
    if (_userType == 'shopkeeper') return AppTheme.shopkeeperPrimary;
    if (_userType == 'receiver') return AppTheme.receiverPrimary;
    return AppTheme.textLight;
  }

  List<Color> get _gradientColors {
    if (_userType == 'shopkeeper') return [AppTheme.shopkeeperPrimary, AppTheme.shopkeeperSecondary];
    if (_userType == 'receiver') return [AppTheme.receiverPrimary, AppTheme.receiverSecondary];
    return [Colors.grey.shade400, Colors.grey.shade600];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Back', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 24),

              // Icon and Title
              Center(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _userType == 'shopkeeper' 
                          ? Icons.store 
                          : _userType == 'receiver' 
                            ? Icons.person 
                            : Icons.group_add, 
                        color: Colors.white, size: 32
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const Text(
                      'Join FoodShare today',
                      style: TextStyle(fontSize: 14, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Dropdown
              const Text('I am a', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: _userType == null ? Colors.grey.shade50 : (_userType == 'shopkeeper' ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4)),
                    border: Border.all(
                      color: _userType == null ? Colors.grey.shade100 : (_userType == 'shopkeeper' ? const Color(0xFFFED7AA) : const Color(0xFFBBF7D0)),
                      width: 2
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _userType == 'shopkeeper' ? const Color(0xFFFFEDD5) : (_userType == 'receiver' ? const Color(0xFFDCFCE7) : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _userType == 'shopkeeper' ? Icons.store : (_userType == 'receiver' ? Icons.person : Icons.person_outline),
                          color: _userType == 'shopkeeper' ? AppTheme.shopkeeperPrimary : (_userType == 'receiver' ? AppTheme.receiverPrimary : AppTheme.textLight),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _userType == 'shopkeeper' ? 'You are a Shopkeeper' : (_userType == 'receiver' ? 'You are a Receiver' : 'Select your role'),
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w500, 
                          color: _userType == null ? AppTheme.textLight : AppTheme.textPrimary
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.keyboard_arrow_down, color: AppTheme.textLight, size: 24),
                    ],
                  ),
                ),
              ),

              if (_isDropdownOpen) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade100, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.store, color: AppTheme.shopkeeperPrimary),
                        title: const Text('You are a Shopkeeper', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: _userType == 'shopkeeper' ? const Icon(Icons.check, color: AppTheme.shopkeeperPrimary) : null,
                        onTap: () => setState(() { _userType = 'shopkeeper'; _isDropdownOpen = false; }),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.person, color: AppTheme.receiverPrimary),
                        title: const Text('You are a Receiver', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: _userType == 'receiver' ? const Icon(Icons.check, color: AppTheme.receiverPrimary) : null,
                        onTap: () => setState(() { _userType = 'receiver'; _isDropdownOpen = false; }),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Form fields (only shown if a role is selected)
              if (_userType != null) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField('Name', 'Enter your full name', Icons.person_outline, _nameController),
                        const SizedBox(height: 16),
                        _buildField('Username', 'Choose a username', Icons.account_circle_outlined, _usernameController),
                        const SizedBox(height: 16),
                        _buildField('Email', 'Enter your email', Icons.email_outlined, _emailController),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 32),
                        
                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _gradientColors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentColor.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: provider.isLoading 
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : ElevatedButton(
                                  onPressed: () async {
                                    if (_userType == null) return;
                                    
                                    final userData = {
                                      'name': _nameController.text.trim(),
                                      'username': _usernameController.text.trim(),
                                      'email': _emailController.text.trim(),
                                      'password': _passwordController.text.trim(),
                                      'role': _userType,
                                    };
                                    
                                    final success = await provider.signup(userData);
                                    if (success && mounted) {
                                      // Logic for account creation
                                      if (_userType == 'shopkeeper') {
                                        Navigator.pushReplacementNamed(context, '/shopkeeper_dashboard');
                                      } else {
                                        Navigator.pushReplacementNamed(context, '/receiver_dashboard');
                                      }
                                    } else if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Signup failed. Please try again.')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                  ),
                                  child: const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Spacer(),
              ],

              // Footer
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: TextStyle(color: _accentColor == AppTheme.textLight ? AppTheme.shopkeeperPrimary : _accentColor, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textLight),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: _accentColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            hintText: 'Create a password',
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textLight),
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textLight),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: _accentColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
