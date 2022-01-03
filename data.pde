void load_data_profile(String input_file, JSONObject data)
{
  JSONObject input = loadJSONObject(input_file);
  data.setString("image_file", input.getString("image_file"));
}
