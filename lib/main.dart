import 'dart:io';
import 'dart:math';
import 'package:canvas_transform_component/models/component_data.dart';
import 'package:canvas_transform_component/models/component_transform.dart';
import 'package:canvas_transform_component/models/component_type.dart';
import 'package:canvas_transform_component/state/state.dart';
import 'package:canvas_transform_component/util/constants.dart';
import 'package:canvas_transform_component/util/extensions.dart';
import 'package:canvas_transform_component/util/utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
part 'widgets/canvas.dart';
part 'widgets/controller_widget.dart';
part 'widgets/creator_widget.dart';
part 'widgets/custom_cursor_widget.dart';
part 'widgets/home_page.dart';
part 'widgets/left_sidebar.dart';
part 'widgets/right_sidebar.dart';
part 'widgets/top_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SelectedCubit()),
        BlocProvider(create: (_) => HoveredCubit()),
        BlocProvider(create: (_) => ComponentIndexCubit()),
        BlocProvider(create: (_) => CanvasCubit()),
        BlocProvider(create: (_) => ComponentsCubit([])),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isSelectedEmpty = context.select(
      (SelectedCubit selected) => selected.state.isEmpty,
    );

    return PlatformMenuBar(
      menus:
          kIsWeb || !Platform.isMacOS
              ? []
              : [
                const PlatformMenu(
                  label: 'Application',
                  menus: [
                    PlatformMenuItemGroup(
                      members: [
                        PlatformProvidedMenuItem(
                          type: PlatformProvidedMenuItemType.about,
                        ),
                      ],
                    ),
                    PlatformMenuItemGroup(
                      members: [PlatformMenuItem(label: 'Preferences')],
                    ),
                    PlatformMenuItemGroup(
                      members: [
                        PlatformProvidedMenuItem(
                          type: PlatformProvidedMenuItemType.minimizeWindow,
                        ),
                        PlatformProvidedMenuItem(
                          type: PlatformProvidedMenuItemType.zoomWindow,
                        ),
                        PlatformProvidedMenuItem(
                          type: PlatformProvidedMenuItemType.hide,
                        ),
                        PlatformProvidedMenuItem(
                          type:
                              PlatformProvidedMenuItemType
                                  .hideOtherApplications,
                        ),
                        PlatformProvidedMenuItem(
                          type: PlatformProvidedMenuItemType.toggleFullScreen,
                        ),
                        PlatformProvidedMenuItem(
                          type: PlatformProvidedMenuItemType.quit,
                        ),
                      ],
                    ),
                  ],
                ),
                const PlatformMenu(
                  label: 'File',
                  menus: [
                    PlatformMenuItem(
                      label: 'New Project',
                      shortcut: SingleActivator(
                        LogicalKeyboardKey.keyN,
                        meta: true,
                      ),
                    ),
                    PlatformMenuItem(
                      label: 'Open Project',
                      shortcut: SingleActivator(
                        LogicalKeyboardKey.keyO,
                        meta: true,
                      ),
                    ),
                    PlatformMenuItem(
                      label: 'Save',
                      shortcut: SingleActivator(
                        LogicalKeyboardKey.keyS,
                        meta: true,
                      ),
                    ),
                    PlatformMenuItem(
                      label: 'Save As',
                      shortcut: SingleActivator(
                        LogicalKeyboardKey.keyS,
                        meta: true,
                        shift: true,
                      ),
                    ),
                    PlatformMenuItem(
                      label: 'Close Project',
                      shortcut: SingleActivator(
                        LogicalKeyboardKey.keyW,
                        meta: true,
                      ),
                    ),
                  ],
                ),
                const PlatformMenu(
                  label: 'Assets',
                  menus: [
                    PlatformMenu(
                      label: 'Import',
                      menus: [PlatformMenuItem(label: 'File')],
                    ),
                  ],
                ),
                PlatformMenu(
                  label: 'Tools',
                  menus: [
                    PlatformMenuItem(
                      label: 'Move',
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyV),
                      onSelected: () => context.read<ToolCubit>().setMove(),
                    ),
                    PlatformMenuItem(
                      label: 'Frame',
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyF),
                      onSelected: () => context.read<ToolCubit>().setFrame(),
                    ),
                    PlatformMenuItem(
                      label: 'Rectangle',
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyR),
                      onSelected:
                          () => context.read<ToolCubit>().setRectangle(),
                    ),
                    PlatformMenuItem(
                      label: 'Hand',
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyH),
                      onSelected: () => context.read<ToolCubit>().setHand(),
                    ),
                    PlatformMenuItem(
                      label: 'Text',
                      shortcut: const SingleActivator(LogicalKeyboardKey.keyT),
                      onSelected: () => context.read<ToolCubit>().setText(),
                    ),
                  ],
                ),
                PlatformMenu(
                  label: 'Shortcuts',
                  menus: [
                    PlatformMenuItem(
                      label: 'Remove Selected',
                      shortcut:
                          Platform.isMacOS
                              ? const SingleActivator(
                                LogicalKeyboardKey.backspace,
                              )
                              : const SingleActivator(
                                LogicalKeyboardKey.delete,
                              ),
                      onSelected:
                          isSelectedEmpty
                              ? null
                              : context.deleteSelectedComponent,
                    ),
                    PlatformMenuItem(
                      label: 'Bring Backward',
                      shortcut: const SingleActivator(
                        LogicalKeyboardKey.bracketLeft,
                      ),
                      onSelected:
                          isSelectedEmpty ? null : context.handleGoBackward,
                    ),
                    PlatformMenuItem(
                      label: 'Bring Forward',
                      shortcut: const SingleActivator(
                        LogicalKeyboardKey.bracketRight,
                      ),
                      onSelected:
                          isSelectedEmpty ? null : context.handleGoForward,
                    ),
                  ],
                ),
              ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Editicert',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CanvasEventsCubit()),
            BlocProvider(create: (_) => CanvasTransformCubit()),
            BlocProvider(create: (_) => KeysCubit()),
            BlocProvider(create: (_) => PointerCubit(Offset.zero)),
            BlocProvider(create: (_) => ToolCubit(ToolType.move)), 
            BlocProvider(create: (_) => DebugPointCubit()),
          ],
          child: const HomePage(),
        ),
      ),
    );
  }
}
