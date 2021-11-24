import 'dart:isolate';
import 'dart:math';

void sort(List<Object> array) async {
  List<int> merge = [];
  SendPort senPort = array.last as SendPort;
  merge = array.first as List<int>;
  int middle = merge.length ~/ 2;

  if (merge.length < 2)
    senPort.send(merge);

  else {
    ReceivePort getPort = ReceivePort();
    Isolate isolate1 = await Isolate.spawn(sort, [merge.sublist(0, middle), getPort.sendPort]);
    Isolate isolate2 = await Isolate.spawn(sort, [merge.sublist(middle, merge.length), getPort.sendPort]);


    List<int> left = [], right = [];
    int i = 0;
    getPort.listen((message){
      switch (i){
        case 0:
          left = message;
          break;
        case 1:
          right = message;
          getPort.close();
          break;
      }
      i++;
    }, onDone: () {
      merge = [];
      while (!(left.isEmpty) || !(right.isEmpty)){
        if (left.isEmpty){
          merge.add(right.first);
          right.removeAt(0);
        } else if (right.isEmpty){
          merge.add(left.first);
          left.removeAt(0);
        } else if (left.first < right.first){
          merge.add(left.first);
          left.removeAt(0);
        } else {
          merge.add(right.first);
          right.removeAt(0);
        }
      }
      senPort.send(merge);
    });
  }
}
void main(){
  List<int> array = List.generate(20, (index) => Random().nextInt(200) - 100);
  ReceivePort mainIsolatePort = ReceivePort();
  print('числа для сортирвки: $array');
  sort([array, mainIsolatePort.sendPort]);

  mainIsolatePort.listen((message){
    array = message;
    mainIsolatePort.close();
  }, onDone: (){
    print('отсортировано: $array');
  });
}