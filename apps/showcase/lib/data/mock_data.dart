import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

class Product {
  const Product(this.id, this.name, this.category, this.price, this.stock, this.icon, {this.sku, this.tag});
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final IconData icon;
  final String? sku;
  final String? tag;
}

const productCategories = ['All', 'Coffee', 'Bakery', 'Food', 'Drinks', 'Retail'];

const products = <Product>[
  Product('p1', 'Flat White', 'Coffee', 4.20, 120, Icons.coffee_rounded, sku: 'COF-001', tag: 'Popular'),
  Product('p2', 'Cappuccino', 'Coffee', 4.00, 98, Icons.coffee_outlined, sku: 'COF-002'),
  Product('p3', 'Cold Brew', 'Coffee', 4.80, 3, Icons.local_cafe_outlined, sku: 'COF-003'),
  Product('p4', 'Butter Croissant', 'Bakery', 3.40, 24, Icons.bakery_dining_rounded, sku: 'BAK-001'),
  Product('p5', 'Almond Danish', 'Bakery', 3.90, 0, Icons.cake_outlined, sku: 'BAK-002'),
  Product('p6', 'Sourdough Loaf', 'Bakery', 7.50, 12, Icons.breakfast_dining_rounded, sku: 'BAK-003'),
  Product('p7', 'Avocado Toast', 'Food', 9.80, 40, Icons.egg_alt_outlined, sku: 'FOO-001', tag: 'New'),
  Product('p8', 'Club Sandwich', 'Food', 11.50, 18, Icons.lunch_dining_rounded, sku: 'FOO-002'),
  Product('p9', 'Caesar Salad', 'Food', 10.90, 22, Icons.rice_bowl_outlined, sku: 'FOO-003'),
  Product('p10', 'Margherita Pizza', 'Food', 13.00, 30, Icons.local_pizza_outlined, sku: 'FOO-004'),
  Product('p11', 'Fresh Orange Juice', 'Drinks', 5.20, 4, Icons.local_drink_outlined, sku: 'DRK-001'),
  Product('p12', 'Sparkling Water', 'Drinks', 2.50, 200, Icons.water_drop_outlined, sku: 'DRK-002'),
  Product('p13', 'Iced Matcha', 'Drinks', 5.60, 60, Icons.emoji_food_beverage_outlined, sku: 'DRK-003'),
  Product('p14', 'Coffee Beans 1kg', 'Retail', 32.00, 15, Icons.inventory_2_outlined, sku: 'RET-001'),
  Product('p15', 'Ceramic Mug', 'Retail', 14.00, 9, Icons.coffee_maker_outlined, sku: 'RET-002'),
  Product('p16', 'Gift Card \$25', 'Retail', 25.00, 999, Icons.card_giftcard_rounded, sku: 'RET-003'),
];

class Order {
  const Order(this.id, this.customer, this.channel, this.items, this.total, this.status, this.time, this.payment);
  final String id;
  final String customer;
  final String channel;
  final int items;
  final double total;
  final PosOrderStatus status;
  final String time;
  final String payment;
}

const orders = <Order>[
  Order('1048', 'Ava Thompson', 'Dine-in', 3, 28.40, PosOrderStatus.preparing, '12:42', 'Card'),
  Order('1047', 'Walk-in', 'Takeaway', 1, 4.20, PosOrderStatus.paid, '12:39', 'Cash'),
  Order('1046', 'Liam Chen', 'Delivery', 5, 61.90, PosOrderStatus.pending, '12:31', 'Online'),
  Order('1045', 'Sofia Rossi', 'Dine-in', 2, 18.60, PosOrderStatus.served, '12:20', 'Card'),
  Order('1044', 'Noah Patel', 'Takeaway', 4, 33.10, PosOrderStatus.ready, '12:12', 'Wallet'),
  Order('1043', 'Walk-in', 'Dine-in', 2, 9.80, PosOrderStatus.paid, '12:05', 'Cash'),
  Order('1042', 'Mia Johnson', 'Delivery', 6, 72.30, PosOrderStatus.refunded, '11:51', 'Card'),
  Order('1041', 'Ethan Brown', 'Dine-in', 3, 26.00, PosOrderStatus.paid, '11:44', 'Card'),
  Order('1040', 'Walk-in', 'Takeaway', 1, 3.40, PosOrderStatus.voided, '11:40', 'Cash'),
  Order('1039', 'Olivia Garcia', 'Dine-in', 7, 94.50, PosOrderStatus.paid, '11:22', 'Split'),
  Order('1038', 'Lucas Martin', 'Takeaway', 2, 8.20, PosOrderStatus.paid, '11:15', 'Wallet'),
  Order('1037', 'Isabella Lee', 'Delivery', 3, 31.70, PosOrderStatus.paid, '11:02', 'Online'),
];

class Customer {
  const Customer(this.name, this.phone, this.email, this.points, this.tier, this.visits, this.spent);
  final String name;
  final String phone;
  final String email;
  final int points;
  final String tier;
  final int visits;
  final double spent;
}

const customers = <Customer>[
  Customer('Ava Thompson', '+1 415 555 0142', 'ava@example.com', 1240, 'Gold', 48, 1290.40),
  Customer('Liam Chen', '+1 415 555 0199', 'liam@example.com', 320, 'Silver', 12, 340.10),
  Customer('Sofia Rossi', '+1 415 555 0113', 'sofia@example.com', 2890, 'Platinum', 102, 3120.00),
  Customer('Noah Patel', '+1 415 555 0177', 'noah@example.com', 80, 'Member', 3, 64.20),
  Customer('Mia Johnson', '+1 415 555 0121', 'mia@example.com', 610, 'Silver', 22, 702.90),
  Customer('Ethan Brown', '+1 415 555 0166', 'ethan@example.com', 1460, 'Gold', 51, 1530.75),
];

class DiningTable {
  const DiningTable(this.name, this.seats, this.status, {this.guests, this.minutes, this.amount, this.round = false});
  final String name;
  final int seats;
  final PosTableStatus status;
  final int? guests;
  final int? minutes;
  final double? amount;
  final bool round;
}

const floors = ['Main hall', 'Terrace', 'Bar'];

const tables = <DiningTable>[
  DiningTable('T1', 2, PosTableStatus.occupied, guests: 2, minutes: 34, amount: 42.80),
  DiningTable('T2', 4, PosTableStatus.free),
  DiningTable('T3', 4, PosTableStatus.reserved),
  DiningTable('T4', 6, PosTableStatus.billing, guests: 5, minutes: 71, amount: 186.20),
  DiningTable('T5', 2, PosTableStatus.free, round: true),
  DiningTable('T6', 2, PosTableStatus.occupied, guests: 2, minutes: 12, amount: 18.40, round: true),
  DiningTable('T7', 8, PosTableStatus.occupied, guests: 7, minutes: 48, amount: 232.00),
  DiningTable('T8', 4, PosTableStatus.cleaning),
  DiningTable('T9', 4, PosTableStatus.free),
  DiningTable('T10', 2, PosTableStatus.reserved, round: true),
  DiningTable('T11', 4, PosTableStatus.occupied, guests: 3, minutes: 22, amount: 61.50),
  DiningTable('T12', 6, PosTableStatus.free),
];

const coffeeModifiers = [
  PosModifierGroup(
    id: 'size',
    title: 'Size',
    required: true,
    options: [
      PosModifierOption('s', 'Small'),
      PosModifierOption('m', 'Medium', price: 0.50),
      PosModifierOption('l', 'Large', price: 0.90),
    ],
  ),
  PosModifierGroup(
    id: 'milk',
    title: 'Milk',
    required: true,
    options: [
      PosModifierOption('whole', 'Whole'),
      PosModifierOption('oat', 'Oat', price: 0.60),
      PosModifierOption('almond', 'Almond', price: 0.60),
      PosModifierOption('none', 'No milk'),
    ],
  ),
  PosModifierGroup(
    id: 'extras',
    title: 'Extras',
    multiple: true,
    max: 3,
    options: [
      PosModifierOption('shot', 'Extra shot', price: 0.80),
      PosModifierOption('vanilla', 'Vanilla syrup', price: 0.50),
      PosModifierOption('caramel', 'Caramel syrup', price: 0.50),
      PosModifierOption('decaf', 'Decaf'),
    ],
  ),
];

const weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const salesThisWeek = [2140.0, 2380.0, 1980.0, 2760.0, 3420.0, 4180.0, 3650.0];
const salesLastWeek = [1980.0, 2100.0, 2210.0, 2440.0, 3010.0, 3720.0, 3380.0];
const hourlyLabels = ['8a', '9a', '10a', '11a', '12p', '1p', '2p', '3p', '4p', '5p'];
const hourlySales = [180.0, 420.0, 380.0, 520.0, 910.0, 860.0, 440.0, 310.0, 280.0, 390.0];
