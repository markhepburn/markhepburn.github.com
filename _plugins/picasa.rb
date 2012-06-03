# Intended to be used in conjunction with javascript which loads the
# thumbnails etc from picasa -- the required argument is the albumid,
# if there's a second argument it is assumed to be the URL and will be
# used in a link.
module Jekyll
  class PicasaGalleryTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      words = text.split
      @albumid = words.shift
      @content = " "
      if words.length > 0
        url = words.shift       # Ignore anything else included
        @content = "<a href=\"#{url}\">View pictures on Picasa</a>"
      end
    end

    def render(context)
      "<div class=\"gallery\" data-album=\"#{@albumid}\"> #{@content}</div>"
    end
  end
end

Liquid::Template.register_tag('picasa', Jekyll::PicasaGalleryTag)
