import 'package:easy_localization/easy_localization.dart';

import '../exports.dart';

typedef DropdownItemBuilder<T> = String Function(T item);

class CustomDropdownButtonFormField<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final DropdownItemBuilder<T> itemBuilder;
  final InputDecoration? decoration;

  const CustomDropdownButtonFormField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.decoration,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: DropdownButtonFormField<T>(
        icon: Container(),
        value: value,
        decoration: InputDecoration(
          hintText: 'choose'.tr(),
          contentPadding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 4),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
          alignLabelWithHint: true,
          hintStyle: TextStyle(
            color: AppColors.grey,
            fontSize: 18.sp,
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Icon(Icons.arrow_drop_down, color: AppColors.black),
          ),
        ),
        style: TextStyle(color: AppColors.black, fontSize: 16.sp),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: AutoSizeText(
              itemBuilder(item),
              maxLines: 1,
              // Use the itemBuilder to display the item
              style: TextStyle(
                color: AppColors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
