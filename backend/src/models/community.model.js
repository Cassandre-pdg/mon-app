// Modèles communauté — tables `groups`, `posts`, `relations` dans Supabase

// Note : table renommée community_groups (groups = mot réservé PostgreSQL)
const groupSchema = {
  id: 'uuid',
  name: 'string',
  description: 'string',
  category: 'string',            // ex: "Freelance tech", "Créatifs", "Consultants"
  member_count: 'number',
  is_public: 'boolean',
  created_by: 'uuid',            // clé étrangère → users.id
  created_at: 'timestamp',
};

const postSchema = {
  id: 'uuid',
  user_id: 'uuid',
  group_id: 'uuid | null',       // null = post global (si applicable)
  content: 'string',
  likes_count: 'number',
  comments_count: 'number',
  created_at: 'timestamp',
  updated_at: 'timestamp',
};

// Note : table renommée user_relations (relations = mot réservé PostgreSQL)
const relationSchema = {
  id: 'uuid',
  follower_id: 'uuid',           // celui qui suit
  following_id: 'uuid',          // celui qui est suivi
  type: 'friend | mentor',
  status: 'pending | accepted | blocked',
  created_at: 'timestamp',
};

// Limite gratuite : 3 posts par semaine
const FREE_WEEKLY_POST_LIMIT = 3;

module.exports = { groupSchema, postSchema, relationSchema, FREE_WEEKLY_POST_LIMIT };
