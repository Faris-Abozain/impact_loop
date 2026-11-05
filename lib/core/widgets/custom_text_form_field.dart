import 'package:impact_loop/core/exports.dart';

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? initialValue;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? borderRadius;
  final bool? enabled;
  final bool isMessage;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  //FocusNode myFocusNode = FocusNode();
  const CustomTextField({
    super.key,
    this.labelText,
    this.prefixIcon,
    this.validator,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.isMessage = false,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.isPassword = false,
    this.onSubmitted,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode myFocusNode = FocusNode();
  bool showPassword = false;
  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      setState(() {
        // color = Colors.black;
      });
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isMessage ? 150.h : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
            enabled: widget.enabled,
            controller: widget.controller,
            expands: false,
            onTap: widget.onTap,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            focusNode: myFocusNode,
            style: getBoldStyle(),
            onChanged: widget.onChanged,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            maxLines: widget.isMessage ? 5 : 1,
            minLines: widget.isMessage ? 5 : 1,
            onFieldSubmitted: widget.onSubmitted,
            initialValue: widget.initialValue,
            obscureText: widget.isPassword ? !showPassword : false,
            decoration: InputDecoration(
                filled: true,
                fillColor: widget.enabled!
                    ? AppColors.white
                    : AppColors.gray.withOpacity(0.5),
                labelText: widget.labelText,
                labelStyle: getRegularStyle(
                    fontHeight: 1.5,
                    color: myFocusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.gray),
                prefixIcon: widget.prefixIcon,
                prefixIconColor:
                    myFocusNode.hasFocus ? AppColors.primary : AppColors.gray,
                suffixIconColor:
                    myFocusNode.hasFocus ? AppColors.primary : AppColors.gray,
                suffixIcon: widget.isPassword
                    ? showPassword
                        ? IconButton(
                            icon: Icon(
                              widget.isPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          )
                        : IconButton(
                            icon: Icon(
                              !widget.isPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            })
                    : widget.suffixIcon,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 18.h),
                hintStyle: getRegularStyle(color: AppColors.gray, fontSize: 14),
                errorStyle: getRegularStyle(color: AppColors.red),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gray, width: 1.5),
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 10.r))),
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gray, width: 1.5),
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 10.r))),
                // focused border style
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 10.r))),

                // error border style
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.red, width: 1.5),
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 10.r))),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.red, width: 1.5),
                    borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 10.r))))),
      ),
    );
  }
}
