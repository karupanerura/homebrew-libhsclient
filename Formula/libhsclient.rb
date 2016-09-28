class Libhsclient < Formula
  desc "HandlerSocket Client library"
  homepage "https://github.com/DeNA/HandlerSocket-Plugin-for-MySQL"
  url "https://github.com/DeNA/HandlerSocket-Plugin-for-MySQL/archive/1.1.2.tar.gz"
  version "1.1.2"
  sha256 "79aafb1e46307d1b5c14d9c91aad1c39ac626432b6adcc2636a03f6a4ccce5fd"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}", "--disable-handlersocket-server"
    system "make"

    ENV.deparallelize
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <handlersocket/hstcpcli.hpp>

      int main(int argc, char *argv[]) {
        dena::config conf;
        conf["host"] = "localhost"; // dummy
        conf["port"] = "9998"; // dummy

        dena::socket_args sargs;
        sargs.set(conf);

        dena::hstcpcli_ptr p = dena::hstcpcli_i::create(sargs);
        return 0;
      }
    EOS
    flags = ["-I#{include}", "-L#{lib}", "-lhsclient"] + ENV.cflags.split
    system ENV.cxx, "-o", "test", "test.cpp", *flags
    system "./test"
  end
end
