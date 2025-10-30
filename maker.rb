# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://docs.brew.sh/rubydoc/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Maker < Formula
  desc "Create social assets for Instagram, Tiktok, App Store screenshots and more in code"
  homepage "https://github.com/longtail-labs/maker.swift"
  url "https://github.com/longtail-labs/maker.swift/archive/refs/tags/v1.0.0.tar.gz"
  version "1.0.0"
  sha256 "aaeee84171593fe7527d767d414559799353a050a3a227b468bb0e554b073545"
  license "MIT"

  depends_on xcode: :build # or: depends_on "swift" => :build

  def install
    system "make", "install", "prefix=#{prefix}", "PRODUCT=maker"
  end

  test do
    system "#{bin}/maker" "import Foundation\n"
  end

  # depends_on "cmake" => :build

  # Additional dependency
  # resource "" do
  #   url ""
  #   sha256 ""
  # end

  # def install
  #   # Remove unrecognized options if they cause configure to fail
  #   # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
  #   system "./configure", "--disable-silent-rules", *std_configure_args
  #   # system "cmake", "-S", ".", "-B", "build", *std_cmake_args
  # end

  # def install
  #   system "swift", "build", "-c", "release"
  #   bin.install ".build/release/maker" # adjust if your product name differs
  # end

  # test do
  #   system "#{bin}/maker", "--help"
  # end
end
