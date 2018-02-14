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

ActiveRecord::Schema.define(version: 20170809102228) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "street"
    t.string   "state"
    t.string   "city"
    t.string   "country"
    t.string   "zipcode"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.datetime "deleted_at"
    t.string   "street2"
    t.string   "addrtext"
    t.string   "label"
    t.integer  "ns_id"
    t.decimal  "latitude",   precision: 15, scale: 10, default: 0.0
    t.decimal  "longitude",  precision: 15, scale: 10, default: 0.0
  end

  add_index "addresses", ["deleted_at"], name: "index_addresses_on_deleted_at", using: :btree
  add_index "addresses", ["latitude", "longitude"], name: "addresses_coordinate_index", using: :btree

  create_table "blocks", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "content_block_id"
  end

  add_index "blocks", ["deleted_at"], name: "index_blocks_on_deleted_at", using: :btree

  create_table "blog_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blog_moderators", force: :cascade do |t|
    t.integer  "blog_id"
    t.integer  "user_id"
    t.integer  "moderator_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "blog_post_attachments", force: :cascade do |t|
    t.integer  "blog_post_id"
    t.integer  "rich_file_id"
    t.integer  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "blog_post_attachments", ["blog_post_id"], name: "index_blog_post_attachments_on_blog_post_id", using: :btree

  create_table "blog_post_blog_categories", force: :cascade do |t|
    t.integer  "blog_post_id"
    t.integer  "blog_category_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "blog_post_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "blog_post_id"
    t.string   "comment"
    t.integer  "parent_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "blog_post_comments", ["blog_post_id"], name: "index_blog_post_comments_on_blog_post_id", using: :btree
  add_index "blog_post_comments", ["parent_id"], name: "index_blog_post_comments_on_parent_id", using: :btree
  add_index "blog_post_comments", ["user_id"], name: "index_blog_post_comments_on_user_id", using: :btree

  create_table "blog_post_tags", force: :cascade do |t|
    t.integer  "blog_post_id"
    t.integer  "tag_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "blog_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "status"
    t.integer  "privacy"
    t.integer  "blog_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "views",         default: 0
    t.string   "title"
    t.string   "summary"
    t.integer  "thumb_id"
    t.string   "slug"
    t.integer  "comment_count", default: 0
  end

  add_index "blog_posts", ["blog_id"], name: "index_blog_posts_on_blog_id", using: :btree
  add_index "blog_posts", ["slug"], name: "index_blog_posts_on_slug", using: :btree

  create_table "blogs", force: :cascade do |t|
    t.string   "name"
    t.string   "short_description"
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "status",            default: 0
  end

  add_index "blogs", ["deleted_at"], name: "index_blogs_on_deleted_at", using: :btree

  create_table "chat_bubbles", force: :cascade do |t|
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer  "user_id"
    t.integer  "lesson_id"
  end

  add_index "chat_bubbles", ["deleted_at"], name: "index_chat_bubbles_on_deleted_at", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message"
    t.boolean  "status"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["deleted_at"], name: "index_comments_on_deleted_at", using: :btree

  create_table "content_blocks", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
    t.string   "slug"
  end

  add_index "content_blocks", ["deleted_at"], name: "index_content_blocks_on_deleted_at", using: :btree

  create_table "contents", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "kind"
    t.text     "data"
    t.integer  "block_id"
    t.boolean  "visible"
    t.string   "input_html"
  end

  add_index "contents", ["deleted_at"], name: "index_contents_on_deleted_at", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string   "title"
    t.string   "country"
    t.string   "symbol"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_categories", force: :cascade do |t|
    t.integer  "parent_id",   default: 0
    t.string   "title"
    t.text     "description"
    t.boolean  "status",      default: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "event_categories", ["parent_id"], name: "index_event_categories_on_parent_id", using: :btree

  create_table "event_category_mappings", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "event_category_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "event_category_mappings", ["event_id"], name: "index_event_category_mappings_on_event_id", using: :btree

  create_table "event_instructors", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "join_type",  default: 0
  end

  add_index "event_instructors", ["event_id"], name: "index_event_instructors_on_event_id", using: :btree
  add_index "event_instructors", ["user_id"], name: "index_event_instructors_on_user_id", using: :btree

  create_table "event_locations", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "street"
    t.string   "state"
    t.string   "city"
    t.string   "country"
    t.string   "zipcode"
    t.decimal  "latitude",   precision: 15, scale: 10, default: 0.0
    t.decimal  "longitude",  precision: 15, scale: 10, default: 0.0
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "event_locations", ["country"], name: "index_event_locations_on_country", using: :btree
  add_index "event_locations", ["event_id"], name: "index_event_locations_on_event_id", using: :btree
  add_index "event_locations", ["latitude", "longitude"], name: "event_locations_coordinate_index", using: :btree

  create_table "event_organizers", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "event_organizers", ["event_id"], name: "index_event_organizers_on_event_id", using: :btree
  add_index "event_organizers", ["user_id"], name: "index_event_organizers_on_user_id", using: :btree

  create_table "event_participants", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "event_participants", ["event_id"], name: "index_event_participants_on_event_id", using: :btree
  add_index "event_participants", ["user_id", "status"], name: "event_participants_user_status_index", using: :btree
  add_index "event_participants", ["user_id"], name: "index_event_participants_on_user_id", using: :btree

  create_table "event_pricings", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "title"
    t.string   "description"
    t.string   "price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "event_pricings", ["event_id"], name: "index_event_pricings_on_event_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "registration_opening_date"
    t.datetime "registration_closing_date"
    t.string   "url"
    t.integer  "status"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "events", ["status"], name: "index_events_on_status", using: :btree

  create_table "forum_members", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "forum_members", ["deleted_at"], name: "index_forum_members_on_deleted_at", using: :btree

  create_table "forum_moderators", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "forum_moderators", ["deleted_at"], name: "index_forum_moderators_on_deleted_at", using: :btree

  create_table "forum_post_attachments", force: :cascade do |t|
    t.integer  "forum_post_id"
    t.integer  "rich_file_id"
    t.integer  "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "forum_post_attachments", ["forum_post_id"], name: "index_forum_post_attachments_on_forum_post_id", using: :btree

  create_table "forum_post_comment_attachments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "forum_post_id"
    t.integer "forum_post_comment_id"
    t.integer "rich_file_id"
  end

  add_index "forum_post_comment_attachments", ["forum_post_comment_id"], name: "index_forum_post_comment_attachments_on_forum_post_comment_id", using: :btree
  add_index "forum_post_comment_attachments", ["forum_post_id"], name: "index_forum_post_comment_attachments_on_forum_post_id", using: :btree
  add_index "forum_post_comment_attachments", ["user_id"], name: "index_forum_post_comment_attachments_on_user_id", using: :btree

  create_table "forum_post_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "forum_post_id"
    t.string   "comment"
    t.integer  "parent_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "forum_post_comments", ["forum_post_id"], name: "index_forum_post_comments_on_forum_post_id", using: :btree
  add_index "forum_post_comments", ["parent_id"], name: "index_forum_post_comments_on_parent_id", using: :btree
  add_index "forum_post_comments", ["user_id"], name: "index_forum_post_comments_on_user_id", using: :btree

  create_table "forum_post_likes", force: :cascade do |t|
    t.integer  "forum_id"
    t.integer  "forum_post_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "forum_post_likes", ["forum_post_id"], name: "index_forum_post_likes_on_forum_post_id", using: :btree

  create_table "forum_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "status"
    t.integer  "forum_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forum_resources", force: :cascade do |t|
    t.integer  "rich_file_id"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "deleted_at"
    t.boolean  "status"
  end

  add_index "forum_resources", ["deleted_at"], name: "index_forum_resources_on_deleted_at", using: :btree
  add_index "forum_resources", ["resource_id", "resource_type"], name: "index_forum_resources_on_resource_id_and_resource_type", using: :btree
  add_index "forum_resources", ["resource_type", "resource_id"], name: "index_forum_resources_on_resource_type_and_resource_id", using: :btree

  create_table "forum_topics", force: :cascade do |t|
    t.integer  "parent_id"
    t.string   "title"
    t.text     "description"
    t.integer  "privacy"
    t.boolean  "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
    t.integer  "position"
    t.integer  "user_id"
  end

  add_index "forum_topics", ["deleted_at"], name: "index_forum_topics_on_deleted_at", using: :btree

  create_table "forums", force: :cascade do |t|
    t.string   "title"
    t.string   "short_description"
    t.text     "description"
    t.integer  "privacy"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "deleted_at"
    t.boolean  "status"
    t.integer  "forum_topic_id"
    t.integer  "rich_file_id"
    t.integer  "user_id"
    t.boolean  "is_sticky",         default: false
  end

  add_index "forums", ["deleted_at"], name: "index_forums_on_deleted_at", using: :btree

  create_table "goal_lessons", force: :cascade do |t|
    t.integer  "goal_id"
    t.integer  "lesson_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "goal_lessons", ["deleted_at"], name: "index_goal_lessons_on_deleted_at", using: :btree

  create_table "goals", force: :cascade do |t|
    t.string   "title"
    t.boolean  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.integer  "rich_file_id"
  end

  add_index "goals", ["deleted_at"], name: "index_goals_on_deleted_at", using: :btree

  create_table "group_members", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "group_members", ["deleted_at"], name: "index_group_members_on_deleted_at", using: :btree

  create_table "group_moderators", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "group_moderators", ["deleted_at"], name: "index_group_moderators_on_deleted_at", using: :btree

  create_table "group_post_attachments", force: :cascade do |t|
    t.integer  "group_post_id"
    t.integer  "rich_file_id"
    t.integer  "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "group_post_attachments", ["group_post_id"], name: "index_group_post_attachments_on_group_post_id", using: :btree

  create_table "group_post_comment_attachments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_post_id"
    t.integer "group_post_comment_id"
    t.integer "rich_file_id"
  end

  add_index "group_post_comment_attachments", ["group_post_comment_id"], name: "index_group_post_comment_attachments_on_group_post_comment_id", using: :btree
  add_index "group_post_comment_attachments", ["group_post_id"], name: "index_group_post_comment_attachments_on_group_post_id", using: :btree
  add_index "group_post_comment_attachments", ["user_id"], name: "index_group_post_comment_attachments_on_user_id", using: :btree

  create_table "group_post_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_post_id"
    t.string   "comment"
    t.integer  "parent_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "group_post_comments", ["group_post_id"], name: "index_group_post_comments_on_group_post_id", using: :btree
  add_index "group_post_comments", ["parent_id"], name: "index_group_post_comments_on_parent_id", using: :btree
  add_index "group_post_comments", ["user_id"], name: "index_group_post_comments_on_user_id", using: :btree

  create_table "group_post_likes", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "group_post_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "group_post_likes", ["group_post_id"], name: "index_group_post_likes_on_group_post_id", using: :btree

  create_table "group_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "status"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "group_id"
    t.string   "groupposting_type"
    t.integer  "groupposting_id"
  end

  create_table "group_requests", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "group_id"
    t.integer  "type"
    t.integer  "user_id"
  end

  add_index "group_requests", ["deleted_at"], name: "index_group_requests_on_deleted_at", using: :btree

  create_table "groups", force: :cascade do |t|
    t.text     "description"
    t.boolean  "status"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "privacy_level"
    t.string   "title"
    t.integer  "rich_file_id"
  end

  create_table "horse_badges", force: :cascade do |t|
    t.integer  "lesson_category_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "horse_id"
  end

  create_table "horse_healths", force: :cascade do |t|
    t.integer "wall_id"
    t.integer "horse_id"
    t.string  "provider"
    t.date    "visit"
    t.date    "next_visit"
    t.integer "visit_type"
    t.text    "note"
    t.text    "assessment"
    t.text    "treatment_outcome"
    t.text    "post_treatment_care"
    t.text    "recommendations"
    t.integer "health_type"
  end

  add_index "horse_healths", ["wall_id"], name: "index_horse_healths_on_wall_id", using: :btree

  create_table "horse_issues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "horse_id"
    t.integer  "issue_id"
  end

  create_table "horse_lessons", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "horse_id"
    t.integer  "lesson_id"
    t.boolean  "completed"
    t.datetime "completed_time"
    t.datetime "last_view"
  end

  add_index "horse_lessons", ["deleted_at"], name: "index_horse_lessons_on_deleted_at", using: :btree

  create_table "horse_progress_logs", force: :cascade do |t|
    t.integer "horse_progress_id"
    t.integer "level_id"
    t.integer "savvy_id"
    t.integer "time"
  end

  add_index "horse_progress_logs", ["horse_progress_id"], name: "index_horse_progress_logs_on_horse_progress_id", using: :btree

  create_table "horse_progresses", force: :cascade do |t|
    t.integer "wall_id"
    t.text    "note"
    t.integer "horse_id"
  end

  add_index "horse_progresses", ["wall_id"], name: "index_horse_progresses_on_wall_id", using: :btree

  create_table "horses", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.integer  "sex"
    t.string   "name"
    t.string   "age"
    t.string   "breed"
    t.integer  "horsenality"
    t.integer  "level_id"
    t.date     "birthday"
    t.string   "color"
    t.string   "height"
    t.string   "weight"
    t.text     "bio"
    t.integer  "rich_file_id"
    t.integer  "goal_id"
  end

  add_index "horses", ["deleted_at"], name: "index_horses_on_deleted_at", using: :btree

  create_table "issue_categories", force: :cascade do |t|
    t.string   "title"
    t.boolean  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer  "goal_id"
  end

  add_index "issue_categories", ["deleted_at"], name: "index_issue_categories_on_deleted_at", using: :btree

  create_table "issues", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "deleted_at"
    t.integer  "savvy_id"
    t.integer  "issue_category_id"
  end

  add_index "issues", ["deleted_at"], name: "index_issues_on_deleted_at", using: :btree

  create_table "item_costs", force: :cascade do |t|
    t.integer  "currency_id"
    t.integer  "membership_type_id"
    t.decimal  "cost"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "learnging_libraries", force: :cascade do |t|
    t.integer  "file_id"
    t.integer  "thumb_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "llcategory_id"
    t.boolean  "featured"
    t.string   "title"
    t.integer  "file_type"
    t.boolean  "status"
    t.integer  "position"
  end

  create_table "lesson_categories", force: :cascade do |t|
    t.string   "title"
    t.integer  "badge_icon_id"
    t.string   "badge_title"
    t.text     "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "deleted_at"
    t.integer  "savvy_id"
    t.integer  "position"
  end

  add_index "lesson_categories", ["deleted_at"], name: "index_lesson_categories_on_deleted_at", using: :btree

  create_table "lesson_resources", force: :cascade do |t|
    t.integer  "lesson_id"
    t.integer  "rich_file_id"
    t.integer  "kind"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.integer  "position"
    t.string   "title"
    t.integer  "video_sub_id"
  end

  add_index "lesson_resources", ["deleted_at"], name: "index_lesson_resources_on_deleted_at", using: :btree

  create_table "lesson_tools", force: :cascade do |t|
    t.string   "title"
    t.integer  "lesson_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer  "position"
  end

  add_index "lesson_tools", ["deleted_at"], name: "index_lesson_tools_on_deleted_at", using: :btree

  create_table "lessons", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.text     "objective"
    t.string   "slug"
    t.integer  "kind"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "deleted_at"
    t.integer  "lesson_category_id"
    t.boolean  "status"
    t.integer  "position"
  end

  add_index "lessons", ["deleted_at"], name: "index_lessons_on_deleted_at", using: :btree

  create_table "level_checklists", force: :cascade do |t|
    t.integer  "level_id"
    t.string   "title"
    t.text     "content"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "levels", force: :cascade do |t|
    t.string   "title"
    t.string   "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer  "slug"
  end

  add_index "levels", ["deleted_at"], name: "index_levels_on_deleted_at", using: :btree

  create_table "llcategories", force: :cascade do |t|
    t.integer  "kind"
    t.integer  "parent_id"
    t.string   "title"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.integer  "rich_file_id"
    t.integer  "position"
  end

  add_index "llcategories", ["deleted_at"], name: "index_llcategories_on_deleted_at", using: :btree

  create_table "memberminute_resources", force: :cascade do |t|
    t.integer  "rich_file_id"
    t.string   "external_url"
    t.string   "title"
    t.integer  "kind"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
    t.integer  "memberminute_section_id"
    t.text     "description"
  end

  add_index "memberminute_resources", ["deleted_at"], name: "index_memberminute_resources_on_deleted_at", using: :btree

  create_table "memberminute_sections", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "title"
    t.text     "description"
    t.boolean  "status"
    t.integer  "memberminute_id"
    t.integer  "kind"
    t.integer  "file_type"
    t.integer  "rich_file_id"
  end

  add_index "memberminute_sections", ["deleted_at"], name: "index_memberminute_sections_on_deleted_at", using: :btree

  create_table "memberminutes", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "publish_date"
    t.datetime "deleted_at"
    t.string   "short_description"
    t.text     "description"
    t.boolean  "status"
    t.string   "memberminute_section"
    t.string   "savvytime_section"
    t.integer  "rich_file_id"
    t.string   "pdf_remote_url"
    t.integer  "pdf_id"
    t.boolean  "featured"
  end

  add_index "memberminutes", ["deleted_at"], name: "index_memberminutes_on_deleted_at", using: :btree

  create_table "membership_cancellations", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "reason"
  end

  add_index "membership_cancellations", ["user_id"], name: "index_membership_cancellations_on_user_id", using: :btree

  create_table "membership_details", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.integer  "membership_type_id"
    t.integer  "billing_frequency"
    t.decimal  "tax"
    t.decimal  "cost"
    t.decimal  "total"
    t.date     "joined_date"
    t.boolean  "status"
    t.integer  "level"
    t.integer  "billing_address_id"
  end

  add_index "membership_details", ["deleted_at"], name: "index_membership_details_on_deleted_at", using: :btree

  create_table "membership_types", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "billing_frequency"
    t.decimal  "tax"
    t.decimal  "cost"
    t.boolean  "status"
    t.integer  "level"
    t.text     "benefits"
    t.string   "item_id"
    t.string   "benefit_title"
  end

  add_index "membership_types", ["deleted_at"], name: "index_membership_types_on_deleted_at", using: :btree

  create_table "message_recipients", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "message_id"
    t.integer  "user_id"
    t.boolean  "status"
  end

  add_index "message_recipients", ["deleted_at"], name: "index_message_recipients_on_deleted_at", using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.boolean  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "messages", ["deleted_at"], name: "index_messages_on_deleted_at", using: :btree

  create_table "notification_recipients", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "notification_id"
    t.integer  "user_id"
  end

  add_index "notification_recipients", ["deleted_at"], name: "index_notification_recipients_on_deleted_at", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.text     "message"
    t.integer  "user_id"
    t.boolean  "status"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "deleted_at"
    t.integer  "notification_type"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
  end

  add_index "notifications", ["deleted_at"], name: "index_notifications_on_deleted_at", using: :btree
  add_index "notifications", ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id", using: :btree

  create_table "page_attachments", force: :cascade do |t|
    t.integer "page_id"
    t.integer "rich_file_id"
    t.string  "title"
  end

  add_index "page_attachments", ["page_id"], name: "index_page_attachments_on_page_id", using: :btree

  create_table "page_tags", force: :cascade do |t|
    t.integer  "page_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "title"
    t.string   "slug"
    t.string   "url"
    t.text     "content"
    t.boolean  "status",       default: true
    t.string   "menu_title"
    t.integer  "position",     default: 0
    t.integer  "display_type", default: 0
    t.integer  "tags"
  end

  add_index "pages", ["slug"], name: "unique_index_pages_on_slug", unique: true, using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "playlist_resources", force: :cascade do |t|
    t.integer  "playlist_id"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "file_id"
    t.string   "title"
  end

  add_index "playlist_resources", ["deleted_at"], name: "index_playlist_resources_on_deleted_at", using: :btree

  create_table "playlists", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "playlists", ["deleted_at"], name: "index_playlists_on_deleted_at", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "message"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "type"
    t.boolean  "status"
    t.integer  "privacy"
    t.text     "content"
    t.integer  "forum_id"
  end

  add_index "posts", ["deleted_at"], name: "index_posts_on_deleted_at", using: :btree

  create_table "privacysettings", force: :cascade do |t|
    t.integer "privacy_type"
    t.integer "status"
    t.integer "user_id"
  end

  create_table "publication_attachments", force: :cascade do |t|
    t.string   "name"
    t.integer  "rich_file_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "savvy_essential_publication_section_id"
  end

  add_index "publication_attachments", ["savvy_essential_publication_section_id"], name: "idx_publction_attchmnts_on_savy_esntial_publction_sction_id", using: :btree

  create_table "publication_sections", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "resources", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "kind"
    t.integer  "rich_file_id"
    t.integer  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "resources", ["user_id"], name: "index_resources_on_user_id", using: :btree

  create_table "rich_rich_files", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rich_file_file_name"
    t.string   "rich_file_content_type"
    t.integer  "rich_file_file_size"
    t.datetime "rich_file_updated_at"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.text     "uri_cache"
    t.string   "simplified_type",                default: "file"
    t.string   "video_ref_id"
    t.string   "video_thumbnail"
    t.integer  "video_length"
    t.string   "video_downloadpath"
    t.string   "video_sourcepath"
    t.integer  "file_status",                    default: 0
    t.string   "low_quality_video_downloadpath"
  end

  create_table "savvies", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.integer  "level_id"
    t.integer  "rich_file_id"
  end

  add_index "savvies", ["deleted_at"], name: "index_savvies_on_deleted_at", using: :btree

  create_table "savvy_essential_publication_sections", force: :cascade do |t|
    t.text     "description"
    t.boolean  "status"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "savvy_essential_publication_id"
    t.integer  "publication_section_id"
    t.integer  "position",                       default: 0
  end

  add_index "savvy_essential_publication_sections", ["publication_section_id"], name: "idx_savy_esntial_publction_sctions_on_publction_sctions_id", using: :btree
  add_index "savvy_essential_publication_sections", ["savvy_essential_publication_id"], name: "idx_savy_esntial_publction_sctions_on_savy_esntial_publction_id", using: :btree

  create_table "savvy_essential_publications", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.date     "publication_date"
    t.boolean  "status"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "savvy_essential_id"
    t.integer  "rich_file_id"
    t.integer  "rich_attachment_id"
    t.string   "additional_content"
  end

  add_index "savvy_essential_publications", ["savvy_essential_id"], name: "index_savvy_essential_publications_on_savvy_essential_id", using: :btree

  create_table "savvy_essentials", force: :cascade do |t|
    t.string   "title"
    t.boolean  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings_scopes", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings_settings", force: :cascade do |t|
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "settings_scope_id"
    t.string   "slug"
    t.string   "title"
    t.string   "value"
    t.integer  "data_type"
    t.integer  "input_type"
    t.string   "input_values"
    t.integer  "order_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
    t.integer  "currency"
    t.integer  "address_id"
    t.integer  "subscrpt_credit_card_id"
    t.boolean  "is_parent"
    t.integer  "entity_id"
    t.integer  "external_id"
    t.string   "display_id"
    t.decimal  "price"
    t.string   "membership_level"
    t.string   "membership_cycle"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "is_auto_renewal"
    t.boolean  "is_active"
    t.boolean  "is_lifetime"
    t.boolean  "is_promotion"
    t.integer  "product"
    t.integer  "charge_status"
    t.date     "inactive_date"
    t.string   "inactive_reason"
  end

  add_index "subscriptions", ["deleted_at"], name: "index_subscriptions_on_deleted_at", using: :btree

  create_table "subscrpt_credit_cards", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.integer  "ns_id"
    t.boolean  "default"
    t.string   "name"
    t.string   "number"
    t.string   "cc_type"
    t.date     "expire_date"
  end

  add_index "subscrpt_credit_cards", ["deleted_at"], name: "index_subscrpt_credit_cards_on_deleted_at", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "testimonials", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "testimonials", ["deleted_at"], name: "index_testimonials_on_deleted_at", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "status"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "topics", ["deleted_at"], name: "index_topics_on_deleted_at", using: :btree

  create_table "user_connections", force: :cascade do |t|
    t.integer  "user_one_id"
    t.integer  "user_two_id"
    t.integer  "connection_status"
    t.integer  "action_user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "user_connections", ["user_one_id", "user_two_id"], name: "index_user_connections_on_user_one_id_and_user_two_id", unique: true, using: :btree
  add_index "user_connections", ["user_one_id"], name: "index_user_connections_on_user_one_id", using: :btree
  add_index "user_connections", ["user_two_id"], name: "index_user_connections_on_user_two_id", using: :btree

  create_table "user_equestrain_interest_mappings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "equestrain_interest_id"
  end

  add_index "user_equestrain_interest_mappings", ["user_id"], name: "index_user_equestrain_interest_mappings_on_user_id", using: :btree

  create_table "user_instructors", force: :cascade do |t|
    t.integer "user_id"
    t.integer "instructor_id"
  end

  add_index "user_instructors", ["user_id"], name: "index_user_instructors_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.integer  "gender"
    t.string   "music"
    t.string   "books"
    t.string   "website"
    t.string   "telephone"
    t.integer  "relationship"
    t.integer  "equestrain_style"
    t.integer  "riding_style"
    t.text     "bio"
    t.datetime "deleted_at"
    t.integer  "home_address_id"
    t.integer  "billing_address_id"
    t.integer  "role"
    t.integer  "profile_picture_id"
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.json     "tokens"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "level_id"
    t.integer  "entity_id"
    t.string   "username"
    t.integer  "nr_instructor_stars"
    t.boolean  "is_instructor"
    t.boolean  "is_instructor_junior"
    t.boolean  "is_staff_member"
    t.boolean  "is_parent"
    t.boolean  "is_child"
    t.boolean  "good_standing"
    t.boolean  "is_disabled"
    t.integer  "legacy_party_id"
    t.boolean  "had_membership"
    t.integer  "currency_id"
    t.integer  "humanity"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wall_post_attachments", force: :cascade do |t|
    t.integer  "wall_id"
    t.integer  "rich_file_id"
    t.integer  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "wall_post_attachments", ["wall_id"], name: "index_wall_post_attachments_on_wall_id", using: :btree

  create_table "wall_post_comment_attachments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "wall_id"
    t.integer "wall_post_comment_id"
    t.integer "rich_file_id"
  end

  add_index "wall_post_comment_attachments", ["user_id"], name: "index_wall_post_comment_attachments_on_user_id", using: :btree
  add_index "wall_post_comment_attachments", ["wall_id"], name: "index_wall_post_comment_attachments_on_wall_id", using: :btree
  add_index "wall_post_comment_attachments", ["wall_post_comment_id"], name: "index_wall_post_comment_attachments_on_wall_post_comment_id", using: :btree

  create_table "wall_post_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "wall_id"
    t.string   "comment"
    t.integer  "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "wall_post_comments", ["parent_id"], name: "index_wall_post_comments_on_parent_id", using: :btree
  add_index "wall_post_comments", ["user_id"], name: "index_wall_post_comments_on_user_id", using: :btree
  add_index "wall_post_comments", ["wall_id"], name: "index_wall_post_comments_on_wall_id", using: :btree

  create_table "wall_post_likes", force: :cascade do |t|
    t.integer  "wall_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "wall_post_likes", ["wall_id"], name: "index_wall_post_likes_on_wall_id", using: :btree

  create_table "wall_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "status"
    t.integer  "wall_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "wall_posts", ["wall_id"], name: "index_wall_posts_on_wall_id", using: :btree

  create_table "wall_solutionmap_posts", force: :cascade do |t|
    t.integer "wall_id"
    t.integer "horse_id"
    t.text    "note"
    t.integer "solutionmap_id"
  end

  add_index "wall_solutionmap_posts", ["wall_id"], name: "index_wall_solutionmap_posts_on_wall_id", using: :btree

  create_table "walls", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "author_id"
    t.integer  "status"
    t.integer  "privacy"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "wallposting_type"
    t.integer  "wallposting_id"
  end

  add_foreign_key "blocks", "content_blocks"
  add_foreign_key "blog_moderators", "blogs"
  add_foreign_key "blog_moderators", "users"
  add_foreign_key "blog_post_attachments", "blog_posts"
  add_foreign_key "blog_post_blog_categories", "blog_categories"
  add_foreign_key "blog_post_blog_categories", "blog_posts"
  add_foreign_key "blog_post_comments", "blog_posts"
  add_foreign_key "blog_post_comments", "users"
  add_foreign_key "blog_post_tags", "blog_posts"
  add_foreign_key "blog_post_tags", "tags"
  add_foreign_key "blog_posts", "blogs"
  add_foreign_key "chat_bubbles", "lessons"
  add_foreign_key "chat_bubbles", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "contents", "blocks"
  add_foreign_key "forum_members", "forums"
  add_foreign_key "forum_members", "users"
  add_foreign_key "forum_moderators", "forums"
  add_foreign_key "forum_moderators", "users"
  add_foreign_key "forum_post_attachments", "forum_posts"
  add_foreign_key "forum_post_comment_attachments", "forum_post_comments"
  add_foreign_key "forum_post_comment_attachments", "forum_posts"
  add_foreign_key "forum_post_comment_attachments", "users"
  add_foreign_key "forum_post_comments", "forum_posts"
  add_foreign_key "forum_post_comments", "users"
  add_foreign_key "forum_post_likes", "forum_posts"
  add_foreign_key "forum_post_likes", "forums"
  add_foreign_key "forum_post_likes", "users"
  add_foreign_key "forum_posts", "forums"
  add_foreign_key "forum_resources", "rich_rich_files", column: "rich_file_id"
  add_foreign_key "forum_topics", "users"
  add_foreign_key "forums", "forum_topics"
  add_foreign_key "goal_lessons", "goals"
  add_foreign_key "goal_lessons", "lessons"
  add_foreign_key "goals", "rich_rich_files", column: "rich_file_id"
  add_foreign_key "group_members", "users"
  add_foreign_key "group_moderators", "users"
  add_foreign_key "group_post_comment_attachments", "group_post_comments"
  add_foreign_key "group_post_comment_attachments", "group_posts"
  add_foreign_key "group_post_comment_attachments", "users"
  add_foreign_key "group_post_comments", "users"
  add_foreign_key "group_post_likes", "group_posts"
  add_foreign_key "group_post_likes", "groups"
  add_foreign_key "group_post_likes", "users"
  add_foreign_key "group_requests", "users"
  add_foreign_key "horse_badges", "horses"
  add_foreign_key "horse_badges", "lesson_categories"
  add_foreign_key "horse_healths", "walls"
  add_foreign_key "horse_issues", "horses"
  add_foreign_key "horse_issues", "issues"
  add_foreign_key "horse_lessons", "horses"
  add_foreign_key "horse_lessons", "lessons"
  add_foreign_key "horse_progress_logs", "horse_progresses"
  add_foreign_key "horse_progresses", "horses"
  add_foreign_key "horse_progresses", "walls"
  add_foreign_key "horses", "goals"
  add_foreign_key "horses", "levels"
  add_foreign_key "horses", "rich_rich_files", column: "rich_file_id"
  add_foreign_key "horses", "users"
  add_foreign_key "issue_categories", "goals"
  add_foreign_key "issues", "issue_categories"
  add_foreign_key "issues", "savvies"
  add_foreign_key "item_costs", "currencies"
  add_foreign_key "item_costs", "membership_types"
  add_foreign_key "learnging_libraries", "llcategories"
  add_foreign_key "learnging_libraries", "rich_rich_files", column: "file_id"
  add_foreign_key "learnging_libraries", "rich_rich_files", column: "thumb_id"
  add_foreign_key "lesson_categories", "rich_rich_files", column: "badge_icon_id"
  add_foreign_key "lesson_categories", "savvies"
  add_foreign_key "lesson_resources", "lessons"
  add_foreign_key "lesson_resources", "rich_rich_files", column: "rich_file_id"
  add_foreign_key "lesson_resources", "rich_rich_files", column: "video_sub_id"
  add_foreign_key "lesson_tools", "lessons"
  add_foreign_key "lessons", "lesson_categories"
  add_foreign_key "llcategories", "rich_rich_files", column: "rich_file_id"
  add_foreign_key "memberminute_resources", "rich_rich_files", column: "rich_file_id"
  add_foreign_key "memberminute_sections", "memberminutes"
  add_foreign_key "membership_cancellations", "users"
  add_foreign_key "membership_details", "addresses", column: "billing_address_id"
  add_foreign_key "membership_details", "membership_types"
  add_foreign_key "membership_details", "users"
  add_foreign_key "message_recipients", "messages"
  add_foreign_key "message_recipients", "users"
  add_foreign_key "messages", "users"
  add_foreign_key "notification_recipients", "notifications"
  add_foreign_key "notification_recipients", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "page_tags", "pages"
  add_foreign_key "page_tags", "tags"
  add_foreign_key "playlist_resources", "playlists"
  add_foreign_key "playlists", "users"
  add_foreign_key "posts", "forums"
  add_foreign_key "posts", "users"
  add_foreign_key "privacysettings", "users"
  add_foreign_key "publication_attachments", "savvy_essential_publication_sections"
  add_foreign_key "resources", "users"
  add_foreign_key "savvies", "levels"
  add_foreign_key "savvies", "rich_rich_files", column: "rich_file_id"
  add_foreign_key "savvy_essential_publication_sections", "publication_sections"
  add_foreign_key "savvy_essential_publication_sections", "savvy_essential_publications"
  add_foreign_key "savvy_essential_publications", "savvy_essentials"
  add_foreign_key "settings_settings", "settings_scopes"
  add_foreign_key "subscriptions", "addresses"
  add_foreign_key "subscriptions", "subscrpt_credit_cards"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "subscrpt_credit_cards", "users"
  add_foreign_key "testimonials", "users"
  add_foreign_key "users", "addresses", column: "billing_address_id"
  add_foreign_key "users", "addresses", column: "home_address_id"
  add_foreign_key "users", "currencies"
  add_foreign_key "users", "levels"
  add_foreign_key "users", "rich_rich_files", column: "profile_picture_id"
  add_foreign_key "wall_post_attachments", "walls"
  add_foreign_key "wall_post_comment_attachments", "users"
  add_foreign_key "wall_post_comment_attachments", "wall_post_comments"
  add_foreign_key "wall_post_comment_attachments", "walls"
  add_foreign_key "wall_post_comments", "users"
  add_foreign_key "wall_post_comments", "walls"
  add_foreign_key "wall_post_likes", "walls"
  add_foreign_key "wall_posts", "walls"
  add_foreign_key "wall_solutionmap_posts", "walls"
end
