import 'dart:io';

void main(List<String> arguments) {
  stdout.write('\napp = 1\ndomain = 2, \nusecase = 3, \npresentation = 4 \nselect action : ');
  String? aksi = stdin.readLineSync();
  if (aksi == "1") {
    print('generate app layer');
    generateApp();
  } else if (aksi == "2") {
    print('generate domain layer');
    generateDomain();
  } else if (aksi == "3") {
    print('generate usecase layer');
    generateUsecase();
  } else if (aksi == "4") {
    print('generate presentation layer');
    generatePresentation();
  } else {
    print('ups invalid input');
  }
}

//==>PRESENTATION

void generatePresentation() {
  stdout.write('enter name presentation (example: login, register, profile, profile_auth) : ');
  String? input = stdin.readLineSync();

  if (input == null) {
    print('Usage: dart generate_presentation_layer.dart <feature_name>');
    return;
  } else {
    final value = input.toSnakeCase();
    final List<Map<String, String>> fileStructure = [
      {
        'path': 'lib/presentation/$value/page/${value}_page.dart',
        'content':
            '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/${value.toSnakeCase()}_controller.dart';

class ${value.toPascalCase()}Page extends StatelessWidget {
  const ${value.toPascalCase()}Page({super.key});

  @override
  Widget build(BuildContext context) {
  final controller = Get.find<${value.toPascalCase()}Controller>();
    return const Scaffold();
  }
}
''',
      },

      {
        'path': 'lib/presentation/$value/controller/${value}_controller.dart',
        'content':
            '''
import 'package:get/get.dart';
import '../../../service/dependency/dependency_injection.dart';


class ${value.toPascalCase()}Controller extends GetxController {
  
  final dep = Get.find<DependencyInjection>();

  @override
  void onInit() {
    printInfo(info: '${value.toPascalCase()}Controller init');
    super.onInit();
  }


  @override
  void onClose() {
    printInfo(info: '${value.toPascalCase()}Controller close');
    super.onInit();
  }
}
''',
      },

      {
        'path': 'lib/service/route/binding/${value}_binding.dart',
        'content':
            '''
import 'package:get/get.dart';
import '../../../presentation/$value/controller/${value}_controller.dart';


class ${value.toPascalCase()}Binding implements Bindings {

  @override
  void dependencies() {
    Get.put(${value.toPascalCase()}Controller());
  }
}
''',
      },
    ];

    _updateRouteFile(value);
    _writeFile(fileStructure);
    print('Presentation $value generation completed. like my repo https://github.com/yandev2');
  }
}

void _updateRouteFile(String value) {
  final routeAppFile = File('lib/service/route/route_app.dart');
  final routeNameFile = File('lib/service/route/route_name.dart');

  if (!routeAppFile.existsSync()) {
    throw Exception('Route App file not found');
  } else {
    final content = routeAppFile.readAsStringSync();

    final import =
        '''
import '../../presentation/$value/page/${value}_page.dart';
import 'binding/${value}_binding.dart';
''';

    final routeApp =
        '''
GetPage(name: RouteName.${value.toCamelCase()}, page: () => ${value.toPascalCase()}Page(), transition: Transition.fade, binding: ${value.toPascalCase()}Binding()),
''';
    var updatedContent = content;

    if (!updatedContent.contains(import)) {
      updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-IMPORT', '''
    $import
    // AUTO-GENERATED-IMPORT
   ''');
    }

    if (!updatedContent.contains(routeApp)) {
      updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-ROUTE', '''
    $routeApp
    // AUTO-GENERATED-ROUTE
   ''');
    }

    routeAppFile.writeAsStringSync(updatedContent);
  }

  if (!routeNameFile.existsSync()) {
    throw Exception('Route Name file not found');
  } else {
    final content = routeNameFile.readAsStringSync();
    final routeName =
        '''
  static const ${value.toCamelCase()} = '/$value';
''';
    var updatedContent = content;

    if (!updatedContent.contains(routeName)) {
      updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-ROUTE', '''
    $routeName
    // AUTO-GENERATED-ROUTE
   ''');
    }

    routeNameFile.writeAsStringSync(updatedContent);
  }
}

//==>USECASE

void generateUsecase() {
  stdout.write('enter name usecase (example: getUsers) : ');
  String? usecaseInput = stdin.readLineSync();

  stdout.write('enter name class repository (example: UserRepository) : ');
  String? repoInput = stdin.readLineSync();

  if (usecaseInput == null || repoInput == null) {
    print('Usage: dart generate_usecase_layer.dart <feature_name>');
    return;
  } else {
    final usecase = usecaseInput.toSnakeCase();
    final repository = repoInput.toSnakeCase();
    if (!repoInput.contains('Repository')) return;
    final List<Map<String, String>> fileStructure = [
      {
        'path':
            'lib/domain/usecase/${repository.replaceAll('_repository', '')}/${usecase}_usecase.dart',
        'content':
            '''
import '../../repository/$repository.dart';

class ${usecase.toPascalCase()}Usecase {
 final ${repository.toPascalCase()} ${repository.toCamelCase()};
 ${usecase.toPascalCase()}Usecase(this.${repository.toCamelCase()});

  Future<dynamic> call() async {
    final result = await ${repository.toCamelCase()}.${usecase.toCamelCase()}();
    return result.fold((e) => throw e, (d) => d);
  }
}
 ''',
      },
    ];

    _updateDependencyUsecaseLayer(usecase, repository);
    _writeFile(fileStructure);
    print('Usecase $usecase generation completed. like my repo https://github.com/yandev2');
  }
}

void _updateDependencyUsecaseLayer(String usecase, String repository) {
  final file = File('lib/service/dependency/dependency_injection.dart');

  if (!file.existsSync()) {
    throw Exception('DependencyInjection file not found');
  }

  final content = file.readAsStringSync();
  final importLine =
      '''
import '../../domain/usecase/${repository.replaceAll('_repository', '')}/${usecase}_usecase.dart';
''';

  final usecaseLine =
      '''
late ${usecase.toPascalCase()}Usecase ${usecase.toCamelCase()}Usecase;
''';

  final initUsecase =
      '''
${usecase.toCamelCase()}Usecase = ${usecase.toPascalCase()}Usecase(${repository.toCamelCase()});
''';

  var updatedContent = content;

  if (!updatedContent.contains(importLine)) {
    updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-IMPORT', '''
  $importLine
  // AUTO-GENERATED-IMPORT
  ''');
  }

  if (!updatedContent.contains(usecaseLine)) {
    updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-USECASE', '''
  $usecaseLine
  // AUTO-GENERATED-USECASE
  ''');
  }

  if (!updatedContent.contains(initUsecase)) {
    updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-INIT', '''
    $initUsecase
    // AUTO-GENERATED-INIT
   ''');
  }

  file.writeAsStringSync(updatedContent);
}

//==>DOMAIN

void generateDomain() {
  stdout.write('enter name domain (example: data, auth, user_data): ');
  String? input = stdin.readLineSync();

  if (input == null) {
    print('Usage: dart generate_domain_layer.dart <feature_name>');
    return;
  } else {
    final value = input.toSnakeCase();
    final List<Map<String, String>> fileStructure = [
      {
        'path': 'lib/data/model/${value}_model.dart',
        'content':
            '''
import '../../domain/entity/${value}_entity.dart';

class ${value.toPascalCase()}Model {
  String? value;
 ${value.toPascalCase()}Model({this.value});

  factory ${value.toPascalCase()}Model.fromJson(Map<String, dynamic> json) {
    return ${value.toPascalCase()}Model(value: json['value'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  factory ${value.toPascalCase()}Model.fromEntity(${value.toPascalCase()}Entity entity) {
    return ${value.toPascalCase()}Model(value: entity.value);
  }

  ${value.toPascalCase()}Entity toEntity() {
    return ${value.toPascalCase()}Entity(value: value);
  }
}
''',
      },
      {
        'path': 'lib/data/repository_impl/${value}_repository_impl.dart',
        'content':
            '''
import 'package:dartz/dartz.dart';
import '../../core/network/api_exception_client.dart';
import '../../domain/repository/${value}_repository.dart';
import '../database/source/${value}_datasource.dart';

class ${value.toPascalCase()}RepositoryImpl implements ${value.toPascalCase()}Repository {
  final ${value.toPascalCase()}Datasource ${value.toCamelCase()}Datasource;
  ${value.toPascalCase()}RepositoryImpl(this.${value.toCamelCase()}Datasource);

    @override
  Future<Either<ApiException, dynamic>> delete(String param)async {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Either<ApiException, dynamic>> get(String param)async {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Either<ApiException, List<dynamic>>> getAll()async {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Either<ApiException, dynamic>> post(String param)async {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future<Either<ApiException, dynamic>> update(String param) async{
    // TODO: implement update
    throw UnimplementedError();
  }
}
 ''',
      },
      {
        'path': 'lib/data/database/source/${value}_datasource.dart',
        'content':
            ''' 
abstract class ${value.toPascalCase()}Datasource {
  Future<List<dynamic>> getAll();
  Future<dynamic> get(String param);
  Future<dynamic> post(String param);
  Future<dynamic> update(String param);
  Future<dynamic> delete(String param);
}
class ${value.toPascalCase()}DatasourceImpl extends ${value.toPascalCase()}Datasource {
  @override
  Future<dynamic> delete(String param)async {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<dynamic> get(String param)async {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getAll() async{
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(String param)async {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future<dynamic> update(String param)async {
    // TODO: implement update
    throw UnimplementedError();
  }
}
    ''',
      },

      {
        'path': 'lib/domain/entity/${value}_entity.dart',
        'content':
            ''' 
import 'package:freezed_annotation/freezed_annotation.dart';

part '${value}_entity.freezed.dart';
part '${value}_entity.g.dart';

@Freezed()
abstract class ${value.toPascalCase()}Entity with _\$${value.toPascalCase()}Entity {
  const factory ${value.toPascalCase()}Entity({
    String? value,
  }) = _${value.toPascalCase()}Entity;

  factory ${value.toPascalCase()}Entity.fromJson(Map<String, dynamic> json) => _\$${value.toPascalCase()}EntityFromJson(json);
}

// run dart run build_runner build
    ''',
      },
      {
        'path': 'lib/domain/repository/${value}_repository.dart',
        'content':
            '''
import '../../core/network/api_exception_client.dart';
import 'package:dartz/dartz.dart';

abstract class ${value.toPascalCase()}Repository {
  Future<Either<ApiException, List<dynamic>>> getAll();
  Future<Either<ApiException, dynamic>> get(String param);
  Future<Either<ApiException, dynamic>> post(String param);
  Future<Either<ApiException, dynamic>> update(String param);
  Future<Either<ApiException, dynamic>> delete(String param);
}
''',
      },
    ];
    _updateDependencyDomainLayer(value);
    _writeFile(fileStructure);
    print(
      'Domain layer $input generation completed. run dart run build_runner build. like my repo https://github.com/yandev2',
    );
  }
}

void _updateDependencyDomainLayer(String value) {
  final file = File('lib/service/dependency/dependency_injection.dart');
  if (!file.existsSync()) {
    throw Exception('DependencyInjection file not found');
  }

  final content = file.readAsStringSync();

  final importLine =
      ''' 
import '../../data/database/source/${value}_datasource.dart';
import '../../data/repository_impl/${value}_repository_impl.dart';
import '../../domain/repository/${value}_repository.dart';
  ''';

  final lateDatasourceLine =
      '''
    late ${value.toPascalCase()}Datasource ${value.toCamelCase()}Datasource;
    late ${value.toPascalCase()}Repository ${value.toCamelCase()}Repository;
''';

  final initDatasourceLine =
      '''
      ${value.toCamelCase()}Datasource = ${value.toPascalCase()}DatasourceImpl();
      ${value.toCamelCase()}Repository = ${value.toPascalCase()}RepositoryImpl(${value.toCamelCase()}Datasource);
''';

  var updatedContent = content;

  if (!updatedContent.contains(importLine)) {
    updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-IMPORT', '''
  $importLine
  // AUTO-GENERATED-IMPORT
  ''');
  }

  if (!updatedContent.contains(lateDatasourceLine)) {
    updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-LATE', '''
  $lateDatasourceLine
  // AUTO-GENERATED-LATE
  ''');
  }

  if (!updatedContent.contains(initDatasourceLine)) {
    updatedContent = updatedContent.replaceFirst('// AUTO-GENERATED-INIT', '''
  $initDatasourceLine
  // AUTO-GENERATED-INIT
  ''');
  }

  file.writeAsStringSync(updatedContent);
}

//==>APP

void generateApp() {
  final List<Map<String, String>> fileStructure = [
    {'path': 'assets/img/'},
    {'path': 'assets/icon/'},
    {'path': 'assets/lottie/'},

    {
      'path': 'pubspec.yaml',
      'content': '''
name: flutter_app
description: "A new Flutter project."

version: 1.0.0+1

environment:
  sdk: ^3.10.4
dependencies:
  flutter:
    sdk: flutter
  get:
  intl: 
  flutter_screenutil:
  flutter_bounceable:
  circle_nav_bar:
  carousel_slider:
  expandable:

  freezed_annotation:
  json_annotation: 
  dartz: 
  path_provider:
  sqflite:
  http:

  cupertino_icons:
   
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.5.4
  freezed: ^3.1.0
  json_serializable: ^6.9.5
  flutter_lints: ^6.0.0
  flutter_launcher_icons:

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/img/icon.png"

flutter:
  uses-material-design: true

  assets:
    - assets/lottie/
    - assets/icon/
    - assets/img/
      
      ''',
    },

    {'path': 'lib/data/model/'},
    {'path': 'lib/data/repository_impl/'},
    {'path': 'lib/data/database/local/'},
    {'path': 'lib/data/database/source/'},

    {'path': 'lib/domain/entity/'},
    {'path': 'lib/domain/repository/'},
    {'path': 'lib/domain/usecase/'},

    {'path': 'lib/presentation/'},

    {
      'path': 'lib/core/widget/app_button.dart',
      'content': r'''
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../enum/app_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_size.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.action,
    required this.type,
    this.icon,
    this.title,
    this.isMax = false,
    this.isPrimary = false,
    this.sized = 12,
  });

  final VoidCallback action;
  final AppStyle type;
  final IconData? icon;
  final String? title;
  final bool? isMax;
  final int? sized;
  final bool? isPrimary;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Bounceable(
        onTap: action,
        child: Container(
          padding: title != null
              ? EdgeInsets.symmetric(horizontal: size(15), vertical: size(10))
              : EdgeInsets.all(size(5)),
          decoration: _decorationButton(context),
          child: Row(
            spacing: size(7),
            mainAxisSize: isMax == false ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [if (icon != null) _iconButton(context), if (title != null) _textButton()],
          ),
        ),
      ),
    );
  }

  BoxDecoration _decorationButton(BuildContext context) {
    return BoxDecoration(
      color: isPrimary == true
          ? Theme.of(context).cardColor
          : switch (type) {
              AppStyle.success => isDark.isTrue ? AppColors.success.darken() : AppColors.success,
              AppStyle.warning => isDark.isTrue ? AppColors.warning.darken() : AppColors.warning,
              AppStyle.danger => isDark.isTrue ? AppColors.danger.darken() : AppColors.danger,
              AppStyle.primary => isDark.isTrue ? AppColors.primary.darken() : AppColors.primary,
            },
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: isDark.isTrue
              ? const Color.fromARGB(31, 255, 255, 255)
              : const Color.fromARGB(31, 0, 0, 0),
          blurRadius: 2,
        ),
      ],
    );
  }

  Text _textButton() {
    return Text(
      '$title',
      textScaler: TextScaler.linear(scale()),
      style: TextStyle(
        color: isPrimary == true
            ? isDark.isTrue
                  ? AppColors.darkText
                  : AppColors.lightText
            : AppColors.white,
        fontSize: size(sized!),
      ),
    );
  }

  Container _iconButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size(2)),
      decoration: BoxDecoration(
        color: isPrimary == true
            ? isDark.isTrue
                  ? AppColors.darkText
                  : AppColors.lightText
            : switch (type) {
                AppStyle.success =>
                  isDark.isTrue ? AppColors.success.lighten(0.3) : AppColors.success.lighten(0.5),
                AppStyle.warning =>
                  isDark.isTrue ? AppColors.warning.lighten(0.3) : AppColors.warning.lighten(0.5),
                AppStyle.danger =>
                  isDark.isTrue ? AppColors.danger.lighten(0.3) : AppColors.danger.lighten(0.5),
                AppStyle.primary =>
                  isDark.isTrue ? AppColors.primary.lighten(0.3) : AppColors.primary.lighten(0.5),
              },
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.add,
        color: isPrimary == true
            ? Theme.of(context).cardColor
            : switch (type) {
                AppStyle.success => isDark.isTrue ? AppColors.success.darken() : AppColors.success,
                AppStyle.warning => isDark.isTrue ? AppColors.warning.darken() : AppColors.warning,
                AppStyle.danger => isDark.isTrue ? AppColors.danger.darken() : AppColors.danger,
                AppStyle.primary => isDark.isTrue ? AppColors.primary.darken() : AppColors.primary,
              },
        size: size(sized! + 3),
      ),
    );
  }
}
''',
    },
    {
      'path': 'lib/core/widget/app_snacbar.dart',
      'content': ''' 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../enum/app_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_size.dart';

class AppDialogPalette {
  static const lightBg = Colors.white;
  static const darkBg = Color(0xFF111827);

  // ignore: deprecated_member_use
  static Color iconBg(Color color) => color.withOpacity(0.15);
}

class AppSnacbarStyle {
  final Color bg;
  final Color bgAccent;
  final Color accent;
  final Color iconBg;
  final Color titleColor;
  final IconData icon;

  const AppSnacbarStyle({
    required this.bg,
    required this.bgAccent,
    required this.accent,
    required this.iconBg,
    required this.titleColor,
    required this.icon,
  });

  static AppSnacbarStyle of(AppStyle type, bool dark) {
    final bg = dark ? AppDialogPalette.darkBg : AppDialogPalette.lightBg;
    final titleColor = dark ? Colors.white : Colors.black;
    switch (type) {
      case AppStyle.success:
        return AppSnacbarStyle(
          bg: bg,
          accent: AppColors.success,
          bgAccent: dark
              ? const Color.fromARGB(255, 32, 46, 33)
              : const Color.fromARGB(255, 220, 255, 222),
          iconBg: AppDialogPalette.iconBg(AppColors.success),
          titleColor: titleColor,
          icon: Icons.check_circle,
        );

      case AppStyle.danger:
        return AppSnacbarStyle(
          bg: bg,
          accent: AppColors.danger,
          bgAccent: dark
              ? const Color.fromARGB(255, 46, 32, 32)
              : const Color.fromARGB(255, 255, 220, 220),
          iconBg: AppDialogPalette.iconBg(AppColors.danger),
          titleColor: titleColor,
          icon: Icons.error,
        );

      case AppStyle.warning:
        return AppSnacbarStyle(
          bg: bg,
          accent: AppColors.warning,
          bgAccent: dark
              ? const Color.fromARGB(255, 46, 41, 32)
              : const Color.fromARGB(255, 255, 243, 220),
          iconBg: AppDialogPalette.iconBg(AppColors.warning),
          titleColor: titleColor,
          icon: Icons.warning_amber_rounded,
        );

      case AppStyle.primary:
        return AppSnacbarStyle(
          bg: bg,
          accent: AppColors.primary,
          bgAccent: dark
              ? const Color.fromARGB(255, 32, 37, 46)
              : const Color.fromARGB(255, 220, 226, 255),
          iconBg: AppDialogPalette.iconBg(AppColors.primary),
          titleColor: titleColor,
          icon: Icons.info,
        );
    }
  }
}

void showAppSnacbar({
  required String title,
  required String message,
  required AppStyle type,
  VoidCallback? onClose,
  Duration duration = const Duration(seconds: 4),
}) {
  final dark = Get.isDarkMode;
  final style = AppSnacbarStyle.of(type, dark);

  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.transparent,
    margin: EdgeInsets.symmetric(horizontal: size(8), vertical: 0),
    duration: duration,
    overlayBlur: 2,
    animationDuration: const Duration(milliseconds: 350),
    isDismissible: true,
    messageText: Container(
      padding: EdgeInsets.symmetric(vertical: size(5)),
      decoration: BoxDecoration(
        border: Border.all(color: dark ? AppColors.darkBg : AppColors.lightBg),
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: AlignmentGeometry.topCenter,
          end: AlignmentGeometry.bottomCenter,
          colors: [style.bgAccent, style.bg],
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: dark ? Color.fromARGB(5, 255, 255, 255) : const Color.fromARGB(17, 0, 0, 0),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: size(36),
          height: size(36),
          decoration: BoxDecoration(color: style.iconBg, shape: BoxShape.circle),
          child: Icon(style.icon, color: style.accent, size: size(20)),
        ),

        title: Padding(
          padding: EdgeInsets.only(bottom: size(5)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  textScaler: TextScaler.linear(scale()),
                  style: TextStyle(
                    fontSize: size(14),
                    fontWeight: FontWeight.w600,
                    color: style.titleColor,
                  ),
                ),
              ),
              if (onClose != null)
                InkWell(
                  onTap: () {
                    Get.back();
                    onClose.call();
                  },
                  child: Icon(Icons.close, size: 18, color: style.titleColor.withOpacity(0.6)),
                ),
            ],
          ),
        ),

        subtitle: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textScaler: TextScaler.linear(scale()),
          style: TextStyle(
            fontSize: size(10),
            height: 1.5,
            color: dark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    ),
  );
}
     ''',
    },
    {
      'path': 'lib/core/widget/app_dialog.dart',
      'content': ''' 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../enum/app_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_size.dart';

class AppDialogPalette {
  static const lightBg = Colors.white;
  static const darkBg = Color(0xFF111827);

  // ignore: deprecated_member_use
  static Color iconBg(Color color) => color.withOpacity(0.15);
}

class AppDialogStyle {
  final Color bg;
  final Color accent;
  final Color iconBg;
  final Color titleColor;
  final IconData icon;

  const AppDialogStyle({
    required this.bg,
    required this.accent,
    required this.iconBg,
    required this.titleColor,
    required this.icon,
  });

  static AppDialogStyle of(AppStyle type, bool dark) {
    final bg = dark ? AppDialogPalette.darkBg : AppDialogPalette.lightBg;
    final titleColor = dark ? Colors.white : Colors.black;

    switch (type) {
      case AppStyle.success:
        return AppDialogStyle(
          bg: bg,
          accent: AppColors.success,
          iconBg: AppDialogPalette.iconBg(AppColors.success),
          titleColor: titleColor,
          icon: Icons.check_circle,
        );

      case AppStyle.danger:
        return AppDialogStyle(
          bg: bg,
          accent: AppColors.danger,
          iconBg: AppDialogPalette.iconBg(AppColors.danger),
          titleColor: titleColor,
          icon: Icons.error,
        );

      case AppStyle.warning:
        return AppDialogStyle(
          bg: bg,
          accent: AppColors.warning,
          iconBg: AppDialogPalette.iconBg(AppColors.warning),
          titleColor: titleColor,
          icon: Icons.warning_amber_rounded,
        );

      case AppStyle.primary:
        return AppDialogStyle(
          bg: bg,
          accent: AppColors.primary,
          iconBg: AppDialogPalette.iconBg(AppColors.primary),
          titleColor: titleColor,
          icon: Icons.info,
        );
    }
  }
}

void showAppDialog({
  required String title,
  required String message,
  required AppStyle type,
  String leftText = 'Back',
  String rightText = 'Okay',
  VoidCallback? onLeft,
  VoidCallback? onRight,
}) {
  final dark = Get.isDarkMode;
  final style = AppDialogStyle.of(type, dark);

  Get.dialog(
    Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: Get.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: style.bg,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              _buildHeaderDialog(style, title),
              SizedBox(height: size(15)),

              /// Message
              _buildMessageDialog(message, dark),
              SizedBox(height: size(20)),

              /// Actions
              _buildActionDialog(onLeft, leftText, style, onRight, rightText),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

Row _buildActionDialog(
  VoidCallback? onLeft,
  String leftText,
  AppDialogStyle style,
  VoidCallback? onRight,
  String rightText,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: () {
          Get.back();
          onLeft?.call();
        },
        child: Text(
          leftText,
          style: TextStyle(color: style.accent, fontSize: size(10)),
          textScaler: TextScaler.linear(scale()),
        ),
      ),
      SizedBox(width: size(12)),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: style.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Get.back();
          onRight?.call();
        },
        child: Text(
          rightText,
          textScaler: TextScaler.linear(scale()),
          style: TextStyle(fontSize: size(10)),
        ),
      ),
    ],
  );
}

Text _buildMessageDialog(String message, bool dark) {
  return Text(
    message,
    textScaler: TextScaler.linear(scale()),
    style: TextStyle(
      fontSize: size(10),
      height: 1.5,
      color: dark ? Colors.white70 : Colors.black87,
    ),
  );
}

Row _buildHeaderDialog(AppDialogStyle style, String title) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: size(36),
        height: size(36),
        decoration: BoxDecoration(color: style.iconBg, shape: BoxShape.circle),
        child: Icon(style.icon, color: style.accent, size: size(20)),
      ),
      SizedBox(width: size(12)),
      Expanded(
        child: Text(
          title,
          textScaler: TextScaler.linear(scale()),
          style: TextStyle(
            fontSize: size(16),
            fontWeight: FontWeight.w600,
            color: style.titleColor,
          ),
        ),
      ),
    ],
  );
}

    ''',
    },
    {'path': 'lib/core/widget/app_image.dart', 'content': ''' // here code '''},
    {'path': 'lib/core/widget/app_error.dart', 'content': ''' // here code '''},
    {'path': 'lib/core/widget/app_loading.dart', 'content': ''' // here code '''},

    {'path': 'lib/core/utils/img.dart', 'content': ''' // here code '''},
    {'path': 'lib/core/utils/icon.dart', 'content': ''' // here code '''},
    {'path': 'lib/core/utils/lottie.dart', 'content': ''' // here code '''},

    {
      'path': 'lib/core/enum/app_style.dart',
      'content': ''' enum AppStyle { primary, warning, success, danger }
 ''',
    },

    {
      'path': 'lib/core/network/api_client.dart',
      'content': r''' 
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'api_exception_client.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const Duration _timeout = Duration(seconds: 10);

  String? _token;
  String? _deviceId;
  String? _locale;

  void setToken(String? token) {
    _token = token;
  }

  void setExtraHeaders({String? deviceId, String? locale}) {
    _deviceId = deviceId;
    _locale = locale;
  }

  Map<String, String> get _defaultHeaders {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (_deviceId != null) {
      headers['X-Device-Id'] = _deviceId!;
    }

    if (_locale != null) {
      headers['Accept-Language'] = _locale!;
    }

    return headers;
  }

  Future<T> get<T>(
    String url, {
    Map<String, String>? headers,
    required T Function(dynamic json) converter,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: {..._defaultHeaders, ...?headers})
          .timeout(_timeout);
      return _handleResponse(response, converter);
    } catch (e) {
      throw _mapException(e);
    }
  }

  Future<T> post<T>(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    required T Function(dynamic json) converter,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(url), headers: {..._defaultHeaders, ...?headers}, body: jsonEncode(body))
          .timeout(_timeout);

      return _handleResponse(response, converter);
    } catch (e) {
      throw _mapException(e);
    }
  }

  T _handleResponse<T>(http.Response response, T Function(dynamic json) converter) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, 'HTTP Error (${response.statusCode})');
    }

    if (response.body.isEmpty) {
      return converter(null);
    }

    final dynamic decoded = json.decode(response.body);

    if (decoded is Map<String, dynamic>) {
      final isSuccess = _isSuccess(decoded);

      if (!isSuccess) {
        throw ApiException(
          _getErrorCode(decoded, response.statusCode),
          _getErrorMessage(decoded),
          fieldErrors: _parseFieldErrors(decoded['errors']),
        );
      }

      return converter(decoded['data'] ?? decoded);
    }

    return converter(decoded);
  }

  bool _isSuccess(Map<String, dynamic> json) {
    if (json.containsKey('status')) {
      return json['status'] == 'success' || json['status'] == true;
    }

    if (json.containsKey('success')) {
      return json['success'] == true;
    }

    if (json.containsKey('code')) {
      final code = json['code'];
      return code == 200 || code == '200';
    }

    return true;
  }

  String _getErrorMessage(Map<String, dynamic> json) {
    return json['message'] ?? json['msg'] ?? json['error'] ?? 'Request gagal';
  }

  int _getErrorCode(Map<String, dynamic> json, int httpCode) {
    if (json['code'] is int) return json['code'];
    if (json['code'] is String) {
      return int.tryParse(json['code']) ?? httpCode;
    }
    return httpCode;
  }

  Map<String, List<String>>? _parseFieldErrors(dynamic errors) {
    if (errors == null) return null;

    if (errors is Map<String, dynamic>) {
      final Map<String, List<String>> result = {};

      errors.forEach((key, value) {
        if (value is List) {
          result[key] = value.map((e) => e.toString()).toList();
        } else {
          result[key] = [value.toString()];
        }
      });

      return result;
    }

    return null;
  }

  Exception _mapException(dynamic e) {
    if (e is ApiException) {
      return e;
    } else if (e is SocketException) {
      return ApiException(0, 'Tidak ada koneksi internet');
    } else if (e is TimeoutException) {
      return ApiException(408, 'Koneksi timeout');
    } else if (e is FormatException) {
      return ApiException(422, 'Format data tidak valid');
    } else {
      return ApiException(500, 'Terjadi kesalahan tidak terduga');
    }
  }
}

    ''',
    },
    {
      'path': 'lib/core/network/api_exception_client.dart',
      'content': r'''
class ApiException implements Exception {
  final int code;
  final String message;
  final Map<String, List<String>>? fieldErrors;

  ApiException(this.code, this.message, {this.fieldErrors});

  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;

  @override
  String toString() => 'ApiException($code): $message | fields: $fieldErrors';
}
      ''',
    },
    {
      'path': 'lib/core/network/doc.txt',
      'content': r'''
📘 API CLIENT DOCUMENTATION

ApiClient adalah HTTP helper terpusat untuk:

GET / POST request

Header global (token, device, locale)

Parsing response fleksibel

Error handling konsisten

Mapping field validation errors

📦 Import
import 'api_client.dart';

🚀 Inisialisasi

ApiClient menggunakan Singleton.

final api = ApiClient.instance;

🔐 Set Global Headers
Set Token (Nullable)
ApiClient.instance.setToken(token);


Jika token == null, header Authorization tidak dikirim.

Set Extra Headers
ApiClient.instance.setExtraHeaders(
  deviceId: 'ANDROID-123',
  locale: 'id',
);


Header yang dikirim:

X-Device-Id
Accept-Language

📥 GET REQUEST
🔹 GET List Data
Future<List<DoaModel>> getAllDoa() async {
  return await ApiClient.instance.get<List<DoaModel>>(
    '$api/doa',
    converter: (json) {
      return (json as List)
          .map((e) => DoaModel.fromJson(e))
          .toList();
    },
  );
}

🔹 GET Single Object
Future<DoaModel> getDoa(int id) async {
  return await ApiClient.instance.get<DoaModel>(
    '$api/doa/$id',
    converter: (json) => DoaModel.fromJson(json),
  );
}

📤 POST REQUEST
Future<DoaModel> createDoa(DoaModel model) async {
  return await ApiClient.instance.post<DoaModel>(
    '$api/doa',
    body: model.toJson(),
    converter: (json) => DoaModel.fromJson(json),
  );
}

🧠 RESPONSE HANDLING RULE

API response boleh berbeda-beda, ApiClient akan menormalkan:

✔ Format Didukung
{
  "status": "success",
  "data": {}
}

{
  "success": true,
  "data": []
}

{
  "code": 200,
  "data": "OK"
}

❌ ERROR HANDLING
✳ Catch ApiException
try {
  await getAllDoa();
} on ApiException catch (e) {
  print(e.code);
  print(e.message);
}

🧾 FIELD VALIDATION ERRORS

Jika API mengirim:

{
  "status": false,
  "message": "Validasi gagal",
  "errors": {
    "email": ["Email wajib diisi"],
    "password": ["Minimal 8 karakter"]
  }
}


Akses di Flutter:

on ApiException catch (e) {
  e.fieldErrors?['email']?.first;
}

⚠️ HTTP STATUS ERROR
Error	Message
No Internet	Tidak ada koneksi internet
Timeout	Koneksi timeout
Invalid JSON	Format data tidak valid
Unknown	Terjadi kesalahan tidak terduga
🧩 CUSTOM HEADER PER REQUEST
ApiClient.instance.get(
  url,
  headers: {
    'X-Custom-Header': 'value',
  },
  converter: ...
);

🧠 BEST PRACTICE

✔ Jangan try-catch di repository
✔ Tangkap error di ViewModel / Controller
✔ Mapping data hanya di converter
✔ Jangan decode JSON manual

🏁 CONTOH REPOSITORY IDEAL
class DoaRepository {
  Future<List<DoaModel>> getAll() {
    return ApiClient.instance.get(
      '$api/doa',
      converter: (json) => (json as List)
          .map(DoaModel.fromJson)
          .toList(),
    );
  }
}

✅ RINGKASAN

Satu API client

Error konsisten

Mudah dibaca

Aman untuk production

Cocok Flutter + Clean Architecture
''',
    },

    {
      'path': 'lib/core/theme/app_size.dart',
      'content': ''' 
import 'package:flutter_screenutil/flutter_screenutil.dart';

double size(int size) {
  return size * ScreenUtil().scaleWidth;
}

double scale() {
  return ScreenUtil().scaleWidth;
}

double sizeHeight(int size) {
  return size * ScreenUtil().scaleHeight;
}

      ''',
    },
    {
      'path': 'lib/core/theme/app_colors.dart',
      'content': '''
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color.fromARGB(255, 20, 100, 250);
  // Status
  static const success = Color.fromARGB(255, 18, 204, 86);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF0EA5E9);
  static const white = Colors.white;
  static const black = Colors.black;

  // Light
  static const lightBg = Color(0xFFF9FAFB);
  static const lightText = Color(0xFF111827);
  static const lightSubText = Color(0xFF6B7280);
  static const lightShadow = Color.fromARGB(104, 83, 83, 83);

  // Dark
  static const darkBg = Color(0xFF111827);
  static const darkText = Color(0xFFF9FAFB);
  static const darkSubText = Color(0xFF9CA3AF);
  static const darkShadow = Color.fromARGB(104, 83, 83, 83);
}

extension ColorX on Color {
  Color lighten([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
      ''',
    },
    {
      'path': 'lib/core/theme/app_theme.dart',
      'content': '''
import 'app_size.dart';
import 'app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

final isDark = false.obs;

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBg,
  primaryColor: AppColors.primary,
  cardColor: AppColors.black,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBg,
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  textTheme: TextTheme(
    titleLarge: TextStyle(
      color: AppColors.darkText,
      fontSize: size(14),
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: AppColors.darkText,
      fontSize: size(12),
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: AppColors.darkText,
      fontSize: size(10),
      fontWeight: FontWeight.bold,
    ),

    bodyLarge: TextStyle(
      color: AppColors.darkText,
      fontSize: size(14),
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: AppColors.darkText,
      fontSize: size(12),
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: AppColors.darkText,
      fontSize: size(10),
      fontWeight: FontWeight.w400,
    ),

    labelLarge: TextStyle(
      color: AppColors.darkSubText,
      fontSize: size(12),
      fontWeight: FontWeight.w400,
    ),
    labelMedium: TextStyle(
      color: AppColors.darkSubText,
      fontSize: size(10),
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(
      color: AppColors.darkSubText,
      fontSize: size(8),
      fontWeight: FontWeight.w400,
    ),
  ),

  colorScheme: ColorScheme.dark(primary: AppColors.primary, error: AppColors.danger),
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBg,
  primaryColor: AppColors.primary,
  cardColor: AppColors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  textTheme: TextTheme(
    titleLarge: TextStyle(
      color: AppColors.lightText,
      fontSize: size(14),
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: AppColors.lightText,
      fontSize: size(12),
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: AppColors.lightText,
      fontSize: size(10),
      fontWeight: FontWeight.bold,
    ),

    bodyLarge: TextStyle(
      color: AppColors.lightText,
      fontSize: size(14),
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: AppColors.lightText,
      fontSize: size(12),
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: AppColors.lightText,
      fontSize: size(10),
      fontWeight: FontWeight.w400,
    ),

    labelLarge: TextStyle(
      color: AppColors.lightSubText,
      fontSize: size(12),
      fontWeight: FontWeight.w400,
    ),
    labelMedium: TextStyle(
      color: AppColors.lightSubText,
      fontSize: size(10),
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(
      color: AppColors.lightSubText,
      fontSize: size(8),
      fontWeight: FontWeight.w400,
    ),
  ),

  colorScheme: ColorScheme.light(primary: AppColors.primary, error: AppColors.danger),
);
        ''',
    },

    {
      'path': 'lib/service/api/api_service.dart',
      'content': '''
final api = "";
      ''',
    },

    {
      'path': 'lib/service/database/sqflite_service.dart',
      'content': r'''
import 'dart:io';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SqfliteService {
  final databaseName = "my_database.db";
  final databaseVersion = 1;

  final tableLoad = 'isLoad';

  Database? database;
  Future<Database> databaseMain() async {
    if (database != null) return database!;
    database = await initDatabase();
    return database!;
  }

  Future initDatabase() async {
    Directory documensDirectory = await getApplicationDocumentsDirectory();
    String path = join(documensDirectory.path, databaseName);
    return openDatabase(
      path,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _create,
    );
  }

  Future _create(Database db, int version) async {
    await db.execute("""
                CREATE TABLE $tableLoad (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  value bool NULL,
                )
              """);
  }
}
      ''',
    },
    {
      'path': 'lib/service/database/sqflite_helper.dart',
      'content': r'''
import 'package:sqflite/sqflite.dart';
import 'sqflite_service.dart';

class SqfLiteHelper {
  SqfLiteHelper._();
  static final SqfLiteHelper instance = SqfLiteHelper._();

  Future<Database> get _db async => await SqfliteService().databaseMain();

  Future<dynamic> insert(
    String table,
    Map<String, dynamic>? data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    if (data == null) return null;
    final db = await _db;
    return await db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
  }

  Future<dynamic> select(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    bool single = false,
  }) async {
    final db = await _db;

    final result = await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit ?? (single ? 1 : null),
    );

    if (single) {
      return result.isNotEmpty ? result.first : null;
    }

    return result;
  }

  Future<dynamic> update(
    String table,
    Map<String, dynamic>? data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (data == null) return 0;
    final db = await _db;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<dynamic> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await _db;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<dynamic> raw(String sql, {List<Object?>? args, bool expectBool = false}) async {
    final db = await _db;
    final result = await db.rawQuery(sql, args);

    if (expectBool) {
      return result.isNotEmpty;
    }

    return result;
  }
}
      ''',
    },
    {
      'path': 'lib/service/database/doc.txt',
      'content': r''' 
📘 SQFLITE HELPER DOCUMENTATION

SqfLiteHelper adalah helper database berbasis sqflite yang menyediakan operasi CRUD fleksibel dengan:

Return dynamic

Parameter nullable

Aman dari SQL Injection

Mudah dipakai di repository

📦 Import
import 'package:sqflite/sqflite.dart';
import 'sqflite_helper.dart';

🚀 Inisialisasi

Helper menggunakan Singleton.

final db = SqfLiteHelper.instance;

🧱 Database Access

Database akan diinisialisasi otomatis saat pertama kali diakses.

Future<Database> get _db async =>
    await SqfliteService().databaseMain();

📥 INSERT DATA
Method
Future<dynamic> insert(
  String table,
  Map<String, dynamic>? data, {
  ConflictAlgorithm conflictAlgorithm =
      ConflictAlgorithm.replace,
})

Contoh
await SqfLiteHelper.instance.insert(
  'doa',
  model.toJson(),
);

Catatan

Jika data == null → return null

Default ConflictAlgorithm.replace

Aman untuk cache & offline sync

📤 SELECT DATA
Method
Future<dynamic> select(
  String table, {
  List<String>? columns,
  String? where,
  List<Object?>? whereArgs,
  String? orderBy,
  int? limit,
  bool single = false,
})

🔹 Ambil Semua Data
final result = await SqfLiteHelper.instance.select(
  'doa',
  orderBy: 'id DESC',
);


Return:

List<Map<String, dynamic>>

🔹 Ambil Satu Data
final data = await SqfLiteHelper.instance.select(
  'doa',
  where: 'id = ?',
  whereArgs: [1],
  single: true,
);


Return:

Map<String, dynamic>? 

Parameter Penting
Parameter	Fungsi
columns	Pilih kolom tertentu
where	Kondisi SQL
whereArgs	Parameter SQL aman
orderBy	Urutan data
limit	Batasi jumlah
single	Ambil satu data
🔁 UPDATE DATA
Method
Future<dynamic> update(
  String table,
  Map<String, dynamic>? data, {
  String? where,
  List<Object?>? whereArgs,
})

Contoh
await SqfLiteHelper.instance.update(
  'doa',
  model.toJson(),
  where: 'id = ?',
  whereArgs: [model.id],
);

🗑 DELETE DATA
Method
Future<dynamic> delete(
  String table, {
  String? where,
  List<Object?>? whereArgs,
})

Contoh
await SqfLiteHelper.instance.delete(
  'doa',
  where: 'id = ?',
  whereArgs: [1],
);

🧪 RAW QUERY
Method
Future<dynamic> raw(
  String sql, {
  List<Object?>? args,
  bool expectBool = false,
})

🔹 Cek Data Ada / Tidak
final exists = await SqfLiteHelper.instance.raw(
  'SELECT 1 FROM doa WHERE id = ? LIMIT 1',
  args: [1],
  expectBool: true,
);


Return:

bool

🔹 Query Biasa
final result = await SqfLiteHelper.instance.raw(
  'SELECT COUNT(*) as total FROM doa',
);

final total = result.first['total'];

⚠️ CATATAN PENTING

raw() menggunakan rawQuery

Gunakan hanya untuk SELECT

Untuk UPDATE / DELETE, gunakan method helper bawaan

🧠 BEST PRACTICE

✔ Helper hanya urus database
✔ Mapping Model dilakukan di Repository
✔ Jangan try-catch berlapis
✔ Gunakan whereArgs untuk keamanan

🏁 KESIMPULAN

SqfLiteHelper = database layer fleksibel

Return dynamic memberi kebebasan mapping

Cocok untuk aplikasi Flutter pemula–menengah

Siap production untuk local storage
       ''',
    },

    {
      'path': 'lib/service/dependency/dependency_injection.dart',
      'content': '''
import 'package:get/get.dart';
// AUTO-GENERATED-IMPORT

class DependencyInjection extends GetxController {
  // AUTO-GENERATED-LATE

  // AUTO-GENERATED-USECASE

  @override
  void onInit() {
   // AUTO-GENERATED-INIT

    super.onInit();
  }
}
      ''',
    },

    {
      'path': 'lib/service/route/binding/main_binding.dart',
      'content': '''
import 'package:get/get.dart';
import '../../dependency/dependency_injection.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(DependencyInjection(), permanent: true);
  }
}
    ''',
    },
    {
      'path': 'lib/service/route/route_name.dart',
      'content': '''
abstract class RouteName {
  static const main = '/';
  // AUTO-GENERATED-ROUTE
}
      ''',
    },
    {
      'path': 'lib/service/route/route_app.dart',
      'content': '''
import 'route_name.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
// AUTO-GENERATED-IMPORT

class RouteApp {
static final route = <GetPage>[
    GetPage(name: RouteName.main, page: () => Container(), transition: Transition.fade),
    // AUTO-GENERATED-ROUTE
];
}
      ''',
    },

    {
      'path': 'lib/main.dart',
      'content': '''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'service/route/binding/main_binding.dart';
import 'service/route/route_app.dart';
import 'service/route/route_name.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return  Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialBinding: MainBinding(),
            initialRoute: RouteName.main,
            getPages: RouteApp.route,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: isDark.isTrue ? ThemeMode.dark : ThemeMode.light,
            home: child,
          ),
        );
      },
    );
  }
}
      ''',
    },
  ];

  _writeFile(fileStructure);
  print(
    'Structure and file generation completed. run flutter pub get and flutter upgrade. like my repo https://github.com/yandev2',
  );
}

//==>EXTENTION

void _writeFile(List<Map<String, String>> fileStructure) {
  for (var file in fileStructure) {
    final filePath = file['path']!;
    final fileContent = file.containsKey('content') ? file['content']! : '';

    // Cek apakah path adalah file atau folder
    if (filePath.endsWith('.dart') || filePath.endsWith('.txt') || filePath.endsWith('.yaml')) {
      // Jika file, buat file dengan konten yang disediakan
      final newFile = File(filePath);
      newFile.parent.createSync(recursive: true);
      if (fileContent.isNotEmpty) {
        newFile.writeAsStringSync(fileContent);
      }
      print('Created file: $filePath');
    } else {
      // Jika folder, buat folder
      final dir = Directory(filePath);
      dir.createSync(recursive: true);
      print('Created folder: $filePath');
    }
  }
}

extension StringFormatter on String {
  /// Mengubah format apapun (Pascal, Camel, Space, Dash) menjadi snake_case
  /// Contoh: "DataLayer", "data Layer", "data-layer" -> "data_layer"
  String toSnakeCase() {
    if (isEmpty) return "";

    return replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (Match m) => '${m[1]}_${m[2]}',
    ).replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'-+'), '_').toLowerCase();
  }

  /// Mengubah ke PascalCase dengan menstandarkan ke snake_case dulu
  String toPascalCase() {
    String snake = toSnakeCase(); // Standarisasi dulu!
    if (snake.isEmpty) return "";
    return snake
        .split('_')
        .map(
          (word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : "",
        )
        .join('');
  }

  /// Mengubah ke camelCase
  String toCamelCase() {
    String pascal = toPascalCase();
    if (pascal.isEmpty) return "";
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// Format: snake_case, PascalCase, camelCase
  String toTripleFormat() {
    return "${toSnakeCase()}, ${toPascalCase()}, ${toCamelCase()}";
  }
}
