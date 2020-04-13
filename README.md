# activestorage-cascade

This gem adds support for cascading services for ActiveStorage.
This is ideal for development or staging environment where database refers
actual objects in the production S3 bucket, but only as read-only.

## Configuration

```
# config/storage.yml
# Services
disk:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: <%= Settings.aws.access_key_id %>
  secret_access_key: <%= Settings.aws.secret_access_key %>
  region: <%= Settings.aws.region %>
  bucket: <%= Settings.aws.bucket %>

# Configuration
development:
  service: Cascade
  primary: disk
  secondary: amazon
```

```
# config/environments/development.rb
Rails.application.configure do
  config.active_storage.service = :development
end
```
