import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<String, dynamic>? taskData;
  bool isLoading = true;
  String? errorMessage;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
    _loadDates(); // Đảm bảo gọi _loadDates trong initState
    _loadCoverImage(); // Thêm hàm tải ảnh vào
  }

  // Hàm tải chi tiết task
  Future<void> _fetchTaskDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/task/${widget.taskId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          taskData = jsonData['data']['list'];
          // Chắc chắn sử dụng dữ liệu từ API nếu có, hoặc từ SharedPreferences
          startDate = taskData?['startDate'] != null
              ? DateTime.parse(taskData?['startDate'])
              : startDate;
          endDate = taskData?['endDate'] != null
              ? DateTime.parse(taskData?['endDate'])
              : endDate;
          // Lưu ảnh vào taskData nếu có trong SharedPreferences
          _loadCoverImage(); // Đảm bảo cập nhật lại ảnh khi tải dữ liệu từ API
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Không thể tải task: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi: $e';
        isLoading = false;
      });
    }
  }

  // Future<void> _updateTask() async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('http://10.0.2.2:3000/api/task/${widget.taskId}'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'name': taskData?['name'],
  //         'description': taskData?['description'],
  //         'startDate': startDate?.toIso8601String(),
  //         'endDate': endDate?.toIso8601String(),
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Cập nhật Task thành công')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Không thể cập nhật Task: ${response.statusCode}')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Lỗi khi cập nhật Task: $e')),
  //     );
  //   }
  // }

  Future<void> _loadDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? startDateStr = prefs.getString('${widget.taskId}_startDate');
    String? endDateStr = prefs.getString('${widget.taskId}_endDate');

    setState(() {
      startDate = startDateStr != null ? DateTime.parse(startDateStr) : null;
      endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;
    });
  }

  Future<void> _saveDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (startDate != null) {
      prefs.setString(
          '${widget.taskId}_startDate', startDate!.toIso8601String());
    }
    if (endDate != null) {
      prefs.setString('${widget.taskId}_endDate', endDate!.toIso8601String());
    }
  }

  // Hàm hiển thị picker ngày
  void _showDatePicker(bool isStartDate) {
    DateTime? tempDate = isStartDate ? startDate : endDate;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isStartDate ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: SfDateRangePicker(
                  initialSelectedDate: tempDate ?? DateTime.now(),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is DateTime) {
                      tempDate = args.value;
                    }
                  },
                  selectionMode: DateRangePickerSelectionMode.single,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Đóng'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isStartDate) {
                          startDate = tempDate;
                        } else {
                          endDate = tempDate;
                        }
                      });
                      _saveDates();
                      Navigator.pop(context);
                    },
                    child: Text('Chọn'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(taskData?['name'] ?? 'Chi tiết Task'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog();
              } else if (value == 'delete') {
                _deleteTask();
              } else if (value == 'cover') {
                _showCoverDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Xóa'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'cover',
                  child: Row(
                    children: [
                      Icon(Icons.image, size: 18),
                      SizedBox(width: 8),
                      Text('Chọn ảnh bìa'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with reduced height
                      if (taskData?['coverImage'] != null)
                        Image.file(
                          File(taskData!['coverImage']),
                          width: double.infinity,
                          height: 150, // Reduced height
                          fit: BoxFit.cover,
                        )
                      else if (taskData?['coverColor'] != null)
                        Container(
                          width: double.infinity,
                          height: 150, // Reduced height
                          color: Color(int.parse(taskData!['coverColor'])),
                        )
                      else
                        SizedBox.shrink(),

                      // Title and description with reduced padding
                      SizedBox(height: 8), // Reduced space
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12.0), // Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Tên Task: ${taskData?['name']}',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Xử lý di chuyển ở đây
                                      print("Di chuyển task");
                                    },
                                    child: Text(
                                      "Di chuyển",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6), // Reduced space
                              Text(
                                  'Mô tả: ${taskData?['description'] ?? 'Không có mô tả'}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),

                      // Date section with reduced space
                      SizedBox(height: 8), // Reduced space
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12.0), // Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ngày bắt đầu: ${startDate != null ? DateFormat('dd/MM/yyyy').format(startDate!) : 'Chưa chọn'}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_calendar,
                                        color: Colors.blue),
                                    onPressed: () => _showDatePicker(true),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.black38),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ngày kết thúc: ${endDate != null ? DateFormat('dd/MM/yyyy').format(endDate!) : 'Chưa chọn'}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_calendar,
                                        color: Colors.blue),
                                    onPressed: () => _showDatePicker(false),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Thêm một phần để hiển thị và chọn vị trí
                      SizedBox(height: 8), // Khoảng cách
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vị trí: ${taskData?['location'] ?? 'Chưa chọn'}',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.location_on, color: Colors.blue),
                                onPressed: () => _showMapPicker(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showEditDialog() {
    // Mở dialog để chỉnh sửa task
    showDialog(
      context: context,
      builder: (context) {
        String updatedName = taskData?['name'] ?? '';
        String updatedDescription = taskData?['description'] ?? '';

        return AlertDialog(
          title: Text('Chỉnh sửa Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Tên Task'),
                controller: TextEditingController(text: updatedName),
                onChanged: (value) => updatedName = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Mô tả Task'),
                controller: TextEditingController(text: updatedDescription),
                onChanged: (value) => updatedDescription = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final response = await http.put(
                    Uri.parse('http://10.0.2.2:3000/api/task/${widget.taskId}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'name': updatedName,
                      'description': updatedDescription,
                    }),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      taskData?['name'] = updatedName;
                      taskData?['description'] = updatedDescription;
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Không thể chỉnh sửa task: ${response.statusCode}')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi chỉnh sửa task: $e')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask() async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/task/delete/${widget.taskId}'),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Quay lại màn hình trước đó
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa task: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa task: $e')),
      );
    }
  }

  //XỬ lý ảnh:
  void _showCoverDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.palette),
              title: Text('Chọn màu sắc'),
              onTap: () {
                Navigator.pop(context);
                _pickColor(); // Hàm chọn màu
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromCamera(); // Hàm chụp ảnh
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Tải ảnh từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromGallery(); // Hàm tải ảnh từ thư viện
              },
            ),
          ],
        );
      },
    );
  }

  void _pickColor() {
    Color selectedColor = Colors.blue; // Màu mặc định

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chọn màu bìa'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  taskData?['coverColor'] = selectedColor.value.toString();
                });

                // Lưu màu sắc vào SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('${widget.taskId}_coverColor',
                    selectedColor.value.toString());

                Navigator.pop(context);
              },
              child: Text('Chọn'),
            ),
          ],
        );
      },
    );
  }

// CHụp ảnh bằng camera:
  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        taskData?['coverImage'] = photo.path;
      });

      // Lưu đường dẫn ảnh vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          '${widget.taskId}_coverImage', photo.path); // Lưu đường dẫn ảnh
    }
  }

  //Tải ảnh từ thư viện:
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        taskData?['coverImage'] = image.path;
      });

      // Lưu đường dẫn ảnh vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          '${widget.taskId}_coverImage', image.path); // Lưu đường dẫn ảnh
    }
  }

  Future<void> _loadCoverImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Tải đường dẫn ảnh
    String? coverImagePath = prefs.getString('${widget.taskId}_coverImage');

    // Tải màu sắc
    String? coverColor = prefs.getString('${widget.taskId}_coverColor');

    setState(() {
      if (coverImagePath != null) {
        taskData?['coverImage'] = coverImagePath; // Cập nhật lại đường dẫn ảnh
      }

      if (coverColor != null) {
        taskData?['coverColor'] = coverColor; // Cập nhật lại màu sắc
      }
    });
  }

  //Xử lý vị trí:
  void _showMapPicker() async {
    final selectedLocation = await showModalBottomSheet<Map<String, double>>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  LatLng(21.0285, 105.8542), // Vị trí ban đầu (ví dụ Hà Nội)
              zoom: 15,
            ),
            onTap: (LatLng latLng) {
              Navigator.pop(context, {
                'latitude': latLng.latitude,
                'longitude': latLng.longitude,
              });
            },
          ),
        );
      },
    );

    if (selectedLocation != null) {
      setState(() {
        // Lưu vị trí đã chọn vào taskData
        taskData?['location'] =
            'Lat: ${selectedLocation['latitude']}, Lng: ${selectedLocation['longitude']}';
        taskData?['latitude'] = selectedLocation['latitude'];
        taskData?['longitude'] = selectedLocation['longitude'];
      });
    }
  }
}
