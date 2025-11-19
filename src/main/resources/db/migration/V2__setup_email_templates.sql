-- Create table with correct column types
CREATE TABLE email_template (
  id BIGSERIAL PRIMARY KEY,
  template_type VARCHAR(32) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
