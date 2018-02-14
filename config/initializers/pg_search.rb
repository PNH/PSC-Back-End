PgSearch.multisearch_options = {
  :using => {
    :tsearch => {
      :prefix => true,
      :dictionary => "english",
      :normalization => 7,
      :any_word => true
      }
    }
}
