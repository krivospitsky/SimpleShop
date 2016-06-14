RailsSettings::Settings.create!([
  {var: "site_title", value: "Диск — всему голова", thing_id: nil, thing_type: nil},
  {var: "site_url", value: "http://localhost", thing_id: nil, thing_type: nil},
  {var: "owner_phone", value: "8(930)8444448", thing_id: nil, thing_type: nil},
  {var: "owner_email", value: "tools_kaluga@mail.ru", thing_id: nil, thing_type: nil},
  {var: "disable_categories", value: "true", thing_id: nil, thing_type: nil},
  {var: "builder", value: "!ruby/class 'SimpleForm::FormBuilder'\n", thing_id: nil, thing_type: nil},
  {var: "html", value: "{}\n", thing_id: nil, thing_type: nil}
])

Admin.create(:email => 'test@example.com', :password => 'password', :password_confirmation => 'password')

Page.create!([
  {name: "Оплата и доставка", text: " Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum eleifend ultrices justo vel porta. Praesent tristique sem a euismod mattis. Nullam malesuada dapibus dui, eget mattis sapien iaculis sit amet. Phasellus purus massa, tincidunt at erat ullamcorper, tincidunt luctus elit. Ut eleifend tortor non felis porttitor, nec sagittis ligula placerat. Suspendisse in augue vestibulum, semper nisi et, consectetur libero. Etiam aliquet libero dui, in pharetra lectus sollicitudin nec.\r\n\r\nCras iaculis tellus tincidunt lorem laoreet sagittis. Aliquam id ultrices arcu, quis dapibus est. Pellentesque tristique vel diam luctus sodales. Proin at enim consectetur, tincidunt orci vel, condimentum erat. Mauris mattis vehicula lorem, nec sodales magna pharetra quis. In lobortis non dolor quis egestas. Pellentesque et felis commodo, volutpat odio ut, rutrum lorem. Curabitur dui odio, adipiscing imperdiet condimentum condimentum, fringilla eu arcu. Duis ac augue felis. Donec mollis dapibus quam, in ultricies nunc tincidunt viverra.\r\n\r\nMorbi nec accumsan felis, vel posuere turpis. Donec vitae diam vitae quam tempor fermentum. Aenean eleifend massa non nunc gravida, sed cursus tortor imperdiet. Curabitur eu est id urna pharetra hendrerit. Cras blandit in erat eget commodo. Donec dignissim varius elit. Phasellus mollis semper nulla in vehicula. Nulla dui ipsum, iaculis nec elit sit amet, imperdiet tincidunt libero. Maecenas ultrices orci tellus, at facilisis justo condimentum quis. Sed id purus libero. Aenean varius sodales sem quis pellentesque. Nulla vulputate laoreet dolor ut placerat. Ut aliquam egestas tincidunt. Etiam fringilla quis mi eu varius. Vestibulum pellentesque justo felis, a varius massa euismod at.\r\n\r\nUt nec nunc enim. Praesent sit amet auctor nibh. Phasellus convallis est pellentesque, ultricies tellus in, ultricies eros. Sed faucibus pellentesque ante id consectetur. Phasellus nec malesuada elit. Etiam in ligula consequat purus rutrum egestas. Fusce varius ornare eros mattis auctor. Duis ut libero nulla.\r\n\r\nNunc quis mi leo. Donec sit amet purus commodo, adipiscing augue ac, ornare lorem. Maecenas euismod aliquet nibh, nec feugiat eros tincidunt non. Curabitur sit amet pharetra diam. Sed vitae erat porttitor, egestas nulla a, sagittis diam. Nunc vehicula consequat justo et rhoncus. Sed ligula turpis, scelerisque in nibh vel, porttitor eleifend turpis", image: nil, enabled: true, sort_order: nil, position: "menu_and_footer"},
  {name: "Контакты", text: "<p>КОНТАКТНАЯ ИНФОРМАЦИЯ</p>\r\n\r\n<p>ИП Давыдов В.Н.&nbsp;</p>\r\n\r\n<p>&nbsp;</p>\r\n\r\n<p>89308444448&nbsp;</p>\r\n\r\n<p>tools_kaluga@mail.ru</p>\r\n", image: nil, enabled: true, sort_order: nil, position: "menu_and_footer"}
])
Product.create!([
  {name: "Диск отрезной по металлу Т41-115 х 1,2 х 22,2 (10/50/400)", description: "<p><strong>Диаметр диска, мм:</strong> 115</p>\r\n\r\n<p><strong>Толщина несущего полотна, мм:</strong> 1.2</p>\r\n\r\n<p><strong>Диаметр посадочного отверстия, мм:</strong> 22,2</p>\r\n", price: 31, sku: "11512", count: nil, enabled: true, sort_order: nil},
  {name: "Диск отрезной по металлу Т41-125 х 1,0 х 22,2 (10/50/400)", description: "<p><strong>Диаметр диска, мм:</strong> 115</p>\r\n\r\n<p><strong>Толщина несущего полотна, мм:</strong> 1.0</p>\r\n\r\n<p><strong>Диаметр посадочного отверстия, мм:</strong> 22,2</p>\r\n", price: 33, sku: "12510", count: nil, enabled: true, sort_order: nil}
])
Promotion.create!([
  {name: "test promotion", description: "", sort_order: nil, enabled: true, has_banner: false, banner: nil, send_mail: false, start_at: "2014-08-07", end_at: "2014-02-07", discount: nil}
])
Image.create!([
  {product_id: 3, image: "54252466_348238264.jpg"},
  {product_id: 4, image: "54252466_348238264.jpg"}
])
RailsSettings::ScopedSettings.create!([
  {var: "site_title", value: "Диск — всему голова", thing_id: nil, thing_type: nil},
  {var: "site_url", value: "http://localhost", thing_id: nil, thing_type: nil},
  {var: "owner_phone", value: "8(930)8444448", thing_id: nil, thing_type: nil},
  {var: "owner_email", value: "tools_kaluga@mail.ru", thing_id: nil, thing_type: nil},
  {var: "disable_categories", value: "true", thing_id: nil, thing_type: nil},
  {var: "builder", value: "!ruby/class 'SimpleForm::FormBuilder'\n", thing_id: nil, thing_type: nil},
  {var: "html", value: "{}\n", thing_id: nil, thing_type: nil}
])
RailsSettings::CachedSettings.create!([
  {var: "site_title", value: "Диск — всему голова", thing_id: nil, thing_type: nil},
  {var: "site_url", value: "http://localhost", thing_id: nil, thing_type: nil},
  {var: "owner_phone", value: "8(930)8444448", thing_id: nil, thing_type: nil},
  {var: "owner_email", value: "tools_kaluga@mail.ru", thing_id: nil, thing_type: nil},
  {var: "disable_categories", value: "true", thing_id: nil, thing_type: nil},
  {var: "builder", value: "!ruby/class 'SimpleForm::FormBuilder'\n", thing_id: nil, thing_type: nil},
  {var: "html", value: "{}\n", thing_id: nil, thing_type: nil}
])
Settings.create!([
  {var: "site_title", value: "Диск — всему голова", thing_id: nil, thing_type: nil},
  {var: "site_url", value: "http://localhost", thing_id: nil, thing_type: nil},
  {var: "owner_phone", value: "8(930)8444448", thing_id: nil, thing_type: nil},
  {var: "owner_email", value: "tools_kaluga@mail.ru", thing_id: nil, thing_type: nil},
  {var: "disable_categories", value: "true", thing_id: nil, thing_type: nil},
  {var: "builder", value: "!ruby/class 'SimpleForm::FormBuilder'\n", thing_id: nil, thing_type: nil},
  {var: "html", value: "{}\n", thing_id: nil, thing_type: nil}
])
