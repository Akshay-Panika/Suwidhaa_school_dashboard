import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String selectedFilter = 'All';
  Map<String, dynamic>? selectedMessage;

  final List<Map<String, dynamic>> messages = const [
    {
      'id': 'M001',
      'sender': 'Dr. Rajesh Kumar',
      'subject': 'Parent-Teacher Meeting',
      'message': 'PTM scheduled for Dec 20, 2024 at 10:00 AM. Please ensure your attendance.',
      'time': '2 hours ago',
      'read': true,
      'priority': 'High',
      'to': 'All Teachers',
      'category': 'Meeting',
      'date': '2024-12-20',
    },
    {
      'id': 'M002',
      'sender': 'Ms. Meera Singh',
      'subject': 'Exam Schedule',
      'message': 'Final exams will start from Jan 15, 2025. Please prepare the question papers.',
      'time': '5 hours ago',
      'read': false,
      'priority': 'High',
      'to': 'All Staff',
      'category': 'Exam',
      'date': '2024-12-15',
    },
    {
      'id': 'M003',
      'sender': 'Mr. Suresh Patel',
      'subject': 'Class Trip',
      'message': 'Educational trip to Science Museum on Dec 25. Parent permission required.',
      'time': '1 day ago',
      'read': true,
      'priority': 'Medium',
      'to': 'Class 8-A',
      'category': 'Trip',
      'date': '2024-12-25',
    },
    {
      'id': 'M004',
      'sender': 'Mrs. Anita Sharma',
      'subject': 'Holiday Notice',
      'message': 'School will remain closed on Dec 25 for Christmas. Happy Holidays!',
      'time': '2 days ago',
      'read': true,
      'priority': 'Low',
      'to': 'All Students',
      'category': 'Notice',
      'date': '2024-12-25',
    },
    {
      'id': 'M005',
      'sender': 'Mr. Vikram Reddy',
      'subject': 'Computer Lab Schedule',
      'message': 'Computer lab timings updated for next week. New schedule attached.',
      'time': '3 days ago',
      'read': false,
      'priority': 'Medium',
      'to': 'All Staff',
      'category': 'Schedule',
      'date': '2024-12-18',
    },
  ];

  final List<String> filterTabs = ['All', 'Unread', 'Important', 'Sent'];

  List<Map<String, dynamic>> get filteredMessages {
    return messages.where((message) {
      switch (selectedFilter) {
        case 'Unread':
          return !message['read'];
        case 'Important':
          return message['priority'] == 'High';
        case 'Sent':
          return message['sender'] == 'Me';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredMessages;
    final unreadCount = messages.where((m) => !m['read']).length;
    final importantCount = messages.where((m) => m['priority'] == 'High').length;
    final totalMessages = messages.length;

    return Container(
      color: Colors.grey[50],
      child: Row(
        children: [
          // Left Panel - Message List
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Messages",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showComposeDialog(context);
                        },
                        icon: Icon(Icons.add, size: 16),
                        label: Text("Compose", style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _buildStatChip("Total", totalMessages.toString(), Colors.blue),
                      SizedBox(width: 8),
                      _buildStatChip("Unread", unreadCount.toString(), Colors.red),
                      SizedBox(width: 8),
                      _buildStatChip("Important", importantCount.toString(), Colors.orange),
                    ],
                  ),
                ),

                SizedBox(height: 8),

                // Filter Tabs
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filterTabs.map((tab) {
                        return _buildFilterTab(tab, selectedFilter == tab);
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                // Message Count
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Showing ${filtered.length} messages",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.refresh, size: 16, color: Colors.grey[400]),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 6),

                // Messages List
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final message = filtered[index];
                      return _buildMessageListItem(message);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right Panel - Message Details
          Container(
            width: 320,
            color: Colors.white,
            child: selectedMessage != null
                ? _buildDetailPanel(selectedMessage!)
                : _buildEmptyDetailPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            "$label: $value",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 6),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[700] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.blue[700]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageListItem(Map<String, dynamic> message) {
    final isSelected = selectedMessage != null && selectedMessage!['id'] == message['id'];

    return Container(
      margin: EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue[50]
            : (message['read'] ? Colors.white : Colors.blue[50]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedMessage = message;
            // Mark as read
            if (!message['read']) {
              message['read'] = true;
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              // Priority Indicator
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPriorityColor(message['priority']),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 10),
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: _getPriorityColor(message['priority']).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: _getPriorityColor(message['priority']),
                  size: 18,
                ),
              ),
              SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message['subject'],
                            style: TextStyle(
                              fontWeight: message['read'] ? FontWeight.normal : FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!message['read'])
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      message['sender'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      message['message'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message['time'],
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(message['priority']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      message['priority'],
                      style: TextStyle(
                        fontSize: 7,
                        color: _getPriorityColor(message['priority']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(Map<String, dynamic> message) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _getPriorityColor(message['priority']).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: _getPriorityColor(message['priority']),
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['subject'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      message['sender'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(message['priority']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            message['priority'],
                            style: TextStyle(
                              fontSize: 9,
                              color: _getPriorityColor(message['priority']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: message['read'] ? Colors.green[50] : Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            message['read'] ? 'Read' : 'Unread',
                            style: TextStyle(
                              fontSize: 9,
                              color: message['read'] ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Details
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem("Message ID", message['id']),
                _detailItem("From", message['sender']),
                _detailItem("To", message['to']),
                _detailItem("Category", message['category']),
                _detailItem("Date", message['date']),
                _detailItem("Time", message['time']),
                _detailItem("Priority", message['priority']),

                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),

                Text(
                  "Message",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    message['message'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showReplyDialog(context, message);
                        },
                        icon: Icon(Icons.reply, size: 16),
                        label: Text("Reply", style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showDeleteDialog(context, message);
                        },
                        icon: Icon(Icons.delete, size: 16),
                        label: Text("Delete", style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetailPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.email_outlined,
            size: 48,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12),
          Text(
            "Select a Message",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          Text(
            "Click on a message to view details",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8),
          Text(
            "No messages found",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Compose Dialog
  void _showComposeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue[700], size: 24),
            SizedBox(width: 8),
            Text("Compose Message", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Container(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _formField("To", Icons.person),
                _formField("Subject", Icons.subject),
                _formDropdown("Priority", ['High', 'Medium', 'Low']),
                _formField("Message", Icons.message, maxLines: 4),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, "Message sent successfully", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: Text("Send", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Reply Dialog
  void _showReplyDialog(BuildContext context, Map<String, dynamic> message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.reply, color: Colors.blue[700], size: 24),
            SizedBox(width: 8),
            Text("Reply to ${message['sender']}", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Subject: ${message['subject']}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "From: ${message['sender']}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              _formField("Message", Icons.message, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, "Reply sent successfully", Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: Text("Send Reply", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _formField(String label, IconData icon, {int maxLines = 1, String? initialValue}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: TextField(
        maxLines: maxLines,
        controller: initialValue != null ? TextEditingController(text: initialValue) : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          isDense: true,
        ),
      ),
    );
  }

  Widget _formDropdown(String label, List<String> items, {String? initialValue}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        value: initialValue != null ? (items.contains(initialValue) ? initialValue : null) : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          prefixIcon: Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey[600]),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          isDense: true,
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (String? newValue) {},
        isExpanded: true,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Message", style: TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text(
              "Are you sure you want to delete this message?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, "Message deleted successfully", Colors.red);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Delete", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 13)),
        backgroundColor: color,
        duration: Duration(seconds: 1),
      ),
    );
  }
}