import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/apps_provider.dart';

class CreateAppScreen extends StatefulWidget {
  const CreateAppScreen({super.key});

  @override
  State<CreateAppScreen> createState() => _CreateAppScreenState();
}

class _CreateAppScreenState extends State<CreateAppScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController(text: '📋');
  final _webhookUrlController = TextEditingController();
  bool _isPublic = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      print('[CreateAppScreen] Creating app: ${_nameController.text}');

      final app = await context.read<AppsProvider>().createApp(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            icon: _iconController.text.trim().isEmpty
                ? '📋'
                : _iconController.text.trim(),
            isPublic: _isPublic,
            webhookUrl: _webhookUrlController.text.trim(),
          );

      if (mounted) {
        if (app != null) {
          print('[CreateAppScreen] App created successfully: ${app.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${app.name} created!')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create app')),
          );
        }
      }
    } catch (e) {
      print('[CreateAppScreen] Error creating app: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New App',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create an App',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: JaNeeTheme.amber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apps contain cards that others can swipe on.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'App Name',
                  hintText: 'e.g., Movie Night Picks',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What will people decide on?',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon (emoji)',
                  hintText: '📋',
                  prefixIcon: Icon(Icons.emoji_emotions_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _webhookUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Webhook URL (optional)',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.webhook_outlined),
                ),
              ),
              const SizedBox(height: 24),

              SwitchListTile(
                title: const Text('Public App'),
                subtitle: const Text('Discoverable by all users'),
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleCreate,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create App'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
