module ProductsHelper
  def product_description(product)
    if product.description == nil
      return ("No description.").html_safe
    else
      return (product.description).html_safe
    end
  end

  def product_photo(product)
    if product.photo_url != "" && product.photo_url != nil
      ("<img src='" + product.photo_url + "' alt='" + product.name + "'/>").html_safe
    else
      ("<img src='https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg' alt='" + product.name + "'/>").html_safe
    end
  end
end
