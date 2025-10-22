import 'package:bloc/bloc.dart';

class MapObserver extends BlocObserver {
  const MapObserver();
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}
