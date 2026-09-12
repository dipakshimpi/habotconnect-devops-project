SELECT
  student_id,
  full_name,
  email,
  owner_email,
  course,
  status,
  created_at,
  schema_version
FROM `divine-bloom-441216-m7.d1_staged_enforced.student_onboarding`
WHERE student_id = 'E2E001';
