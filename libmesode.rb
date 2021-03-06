class Libmesode < Formula
  desc "XMPP library for C"
  homepage "https://github.com/profanity-im/libmesode"
  url "https://github.com/profanity-im/libmesode/releases/download/0.9.3/libmesode-0.9.3.tar.gz"
  sha256 "fba43fa7a27c75f1b65068efa564f840b9cccc5997cb92f9a0c908fdf964c776"
  head "https://github.com/profanity-im/libmesode.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "check"
  depends_on "openssl@1.1"
  uses_from_macos "libxml2"

  def install
    system "./bootstrap.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <mesode.h>
      #include <assert.h>
      int main(void) {
        xmpp_ctx_t *ctx;
        xmpp_log_t *log;
        xmpp_initialize();
        log = xmpp_get_default_logger(XMPP_LEVEL_DEBUG);
        assert(log);
        ctx = xmpp_ctx_new(NULL, log);
        assert(ctx);
        xmpp_ctx_free(ctx);
        xmpp_shutdown();
        return 0;
      }
    EOS
    flags = ["-I#{include}/", "-L#{lib}", "-lmesode"]
    system ENV.cc, "-o", "test", "test.c", *(flags + ENV.cflags.to_s.split)
    system "./test"
  end
end