# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180109120610) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "attrs", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.boolean  "variantable"
    t.integer  "product_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "blogo_posts", force: :cascade do |t|
    t.integer  "user_id",          null: false
    t.string   "permalink",        null: false
    t.string   "title",            null: false
    t.boolean  "published",        null: false
    t.datetime "published_at",     null: false
    t.string   "markup_lang",      null: false
    t.text     "raw_content",      null: false
    t.text     "html_content",     null: false
    t.text     "html_overview"
    t.string   "tags_string"
    t.string   "meta_description", null: false
    t.string   "meta_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogo_posts", ["permalink"], name: "index_blogo_posts_on_permalink", unique: true, using: :btree
  add_index "blogo_posts", ["published_at"], name: "index_blogo_posts_on_published_at", using: :btree
  add_index "blogo_posts", ["user_id"], name: "index_blogo_posts_on_user_id", using: :btree

  create_table "blogo_taggings", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "tag_id",  null: false
  end

  add_index "blogo_taggings", ["tag_id", "post_id"], name: "index_blogo_taggings_on_tag_id_and_post_id", unique: true, using: :btree

  create_table "blogo_tags", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogo_tags", ["name"], name: "index_blogo_tags_on_name", unique: true, using: :btree

  create_table "blogo_users", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogo_users", ["email"], name: "index_blogo_users_on_email", unique: true, using: :btree

  create_table "cart_items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "cart_id"
    t.integer  "quantity"
    t.integer  "variant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["product_id"], name: "index_cart_items_on_product_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "parent_id"
    t.string   "image"
    t.boolean  "enabled"
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "external_id"
    t.integer  "vk_id"
    t.integer  "vk_id2"
    t.integer  "ok_id",       limit: 8
  end

  create_table "categories_discounts", force: :cascade do |t|
    t.integer "discount_id"
    t.integer "category_id"
  end

  create_table "categories_linked_categories", force: :cascade do |t|
    t.integer "category_id"
    t.integer "linked_category_id"
  end

  create_table "categories_linked_products", force: :cascade do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  create_table "categories_products", force: :cascade do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delivery_methods", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "hide"
    t.boolean  "enabled"
    t.integer  "sort_order"
    t.integer  "min_price"
    t.integer  "max_price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "price"
  end

  create_table "delivery_methods_payment_methods", force: :cascade do |t|
    t.integer "delivery_method_id"
    t.integer "payment_method_id"
  end

  create_table "description_images", force: :cascade do |t|
    t.string   "original_url"
    t.string   "image"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.string   "name"
    t.boolean  "enabled"
    t.date     "start_at"
    t.date     "end_at"
    t.integer  "discount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discounts_products", force: :cascade do |t|
    t.integer "discount_id"
    t.integer "product_id"
  end

  create_table "images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", force: :cascade do |t|
    t.string   "product_name"
    t.string   "product_sku"
    t.integer  "product_id"
    t.integer  "price"
    t.integer  "discount_price"
    t.integer  "quantity"
    t.integer  "order_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "cart_id"
    t.string   "state"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "zip"
    t.string   "city"
    t.string   "address"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secure_key"
    t.integer  "delivery_method_id"
    t.integer  "payment_method_id"
    t.string   "passport"
    t.string   "card_number"
    t.integer  "discount"
  end

  create_table "pages", force: :cascade do |t|
    t.string   "name"
    t.text     "text"
    t.string   "image"
    t.boolean  "enabled"
    t.integer  "sort_order"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "hide"
    t.boolean  "enabled"
    t.integer  "sort_order"
    t.boolean  "use_online"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "online_type"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "sort_order"
    t.integer  "price"
    t.string   "sku"
    t.integer  "count"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "min_price"
    t.integer  "max_price"
    t.string   "external_id"
    t.datetime "returned_at"
    t.integer  "vk_id"
    t.integer  "vk_id2"
    t.integer  "ok_id",        limit: 8
    t.string   "typePrefix"
    t.string   "vendor"
    t.string   "model"
    t.string   "color"
    t.string   "yml_name"
    t.string   "picture_type"
  end

  add_index "products", ["external_id"], name: "index_products_on_external_id", using: :btree

  create_table "products_linked_categories", force: :cascade do |t|
    t.integer "product_id"
    t.integer "category_id"
  end

  create_table "products_linked_products", force: :cascade do |t|
    t.integer "product_id"
    t.integer "linked_product_id"
  end

  create_table "seos", force: :cascade do |t|
    t.integer  "seoable_id"
    t.string   "seoable_type"
    t.string   "title"
    t.text     "keywords"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "slides", force: :cascade do |t|
    t.string   "name"
    t.boolean  "enabled"
    t.string   "image"
    t.string   "url"
    t.date     "start_at"
    t.date     "end_at"
    t.integer  "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "text_blocks", force: :cascade do |t|
    t.string   "name"
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "card_number"
    t.integer  "discount"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "variant_attrs", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "variant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "name"
    t.string   "sku"
    t.integer  "price"
    t.integer  "count"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.string   "availability"
    t.string   "external_id"
  end

  add_index "variants", ["external_id"], name: "index_variants_on_external_id", using: :btree

end
