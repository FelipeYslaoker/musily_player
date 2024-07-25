import 'package:flutter/material.dart';

class AppAnimatedDialog extends StatefulWidget {
  final Widget Function(BuildContext context, void Function() onClose) builder;

  const AppAnimatedDialog({
    required this.builder,
    super.key,
  });

  @override
  State<AppAnimatedDialog> createState() => _AppAnimatedDialogState();
}

class _AppAnimatedDialogState extends State<AppAnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Começa com o dialog abaixo da tela
      end: Offset.zero, // Termina com o dialog na posição normal
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward(); // Inicia a animação imediatamente
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _hideDialog() {
    _controller.reverse().then((_) {
      Navigator.of(context).pop(); // Fecha o dialog depois da animação
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, _) {
        return SlideTransition(
          position: _offsetAnimation, // Aplica a animação de slide
          child: widget.builder(
            context,
            () {
              _hideDialog();
            },
          ),
        );
      },
    );
  }
}
